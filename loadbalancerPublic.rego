package exposure

# We check for LoadBalancers with public IPs that have the exposure level set to anything other than internet

loadBalancerService[service] {
  service := servicesWithExposureLevel[_]
  service.type == "LoadBalancer"
  service.externalIP
}

loadBalancerServiceWithPrivateIP[service] {
  service := loadBalancerService[_]
  private_subnets := data.rfc1819Subnets[_]
  net.cidr_contains(private_subnets, service.externalIP)
}

loadBalancerServiceWithPublicIP[service] {
  service := loadBalancerService[_]
  not loadBalancerServiceWithPrivateIP[service]
}

violations[msg] {
  service := loadBalancerServiceWithPublicIP[_]
  not service.exposureLevel == "internet"
  msg := sprintf("LoadBalancer services with public IPs must have an annotation indicating that their exposure level is 'internet'.  service=%s/%s ipaddress=%s", [service.namespace, service.name, service.externalIP])
}

violations[msg] {
  service := loadBalancerServiceWithPrivateIP[_]
  exposureLevels[service.exposureLevel] < exposureLevels["intranet"]
  msg := sprintf("LoadBalancer services must have an annotation indicating that their exposure level is either internet or intranet.  service=%s/%s ipaddress=%s", [service.namespace, service.name, service.externalIP])
}
