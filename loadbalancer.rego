package exposure

# Currently we ignore ClusterIP and NodePort services that point to ingress controllers.. what are the implications of this?
# TODO: we need better matching of selectors to labels.. right now we only have equality
# TODO: add support for multiple exposure levels (internet, intranet, and cluster)
# TODO: add support for services that point directly to pods (via deployments/daemonsets/statefulsets, etc) but we can just match the service selector to the pods
# TODO: true the schema up to what actual Services/Pods/Ingress look like.  How to actually express an IGC?  How to get the ingressClass from an Ingress controller? or do we even need to?
# TODO: add test

loadBalancerService[service] {
  service := servicesWithExposureLevel[_]
  service.type == "LoadBalancer"
  service.externalIP
}

loadBalancerServiceWithPrivateIP[service] {
  service := loadBalancerService[_]
  private_subnets := data.rfc1819_subnets[_]
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
