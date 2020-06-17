package exposure

# Here we want to find ingress objects that contain at least one hostname which resolves to public IPs but which doesnt have an exposure annotation of internet
# In the realworld ingress objects dont store their IP-address as part of the data hash...
#
#
# TOOD: this logic does not currently work!!

ingressesResolvingToOnlyPrivateIPs[ingressWithExposureLevel] {
  ingressWithExposureLevel := ingressesWithExposureLevel[_]
  private_subnets := data.rfc1819_subnets[_]

  total_addresses := { ipaddress | ipaddress := ingressWithExposureLevel.hostnames[_] }
  private_addresses := { ipaddress | ipaddress := ingressWithExposureLevel.hostnames[_]; net.cidr_contains(private_subnets, ipaddress) }

  count(private_addresses) == count(total_addresses)
}

ingressesResolvingToPublicIPs[ingressWithExposureLevel] {
  ingressWithExposureLevel := ingressesWithExposureLevel[_]
  not ingressesResolvingToOnlyPrivateIPs[ingressWithExposureLevel]
}

violations[msg] {
  ingressResolvingToPublicIP := ingressesResolvingToPublicIPs[_]
  not ingressResolvingToPublicIP.exposureLevel == "internet"

  # TODO: Need to figure how to get the hostname/ipaddress in here
  # couldnt we do:  public_addresses := { ipaddress | ipaddress := ingressWithExposureLevel.hostnames[_]; not net.cidr_contains(private_subnets, ipaddress)
  # count(public_addresses) > 0 ?   maybe we could then keep the public_addresses and pass it into the violation
  msg := sprintf("Ingresses with at least one hostname that resolves to a public IP must have an annotation indicating that its exposure level is 'internet'. ingress=%s/%s", [ingressResolvingToPublicIP.namespace, ingressResolvingToPublicIP.name])
}
