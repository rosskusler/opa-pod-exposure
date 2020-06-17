package exposure

# We want to find ingress objects that contain at least one hostname which resolves to public IPs but which doesnt have an exposure annotation of internet
# In the realworld ingress objects dont store their IP-address as part of the data hash...
#

ingressesResolvingToOnlyPrivateIPs[ingressWithExposureLevel] {
  ingressWithExposureLevel := ingressesWithExposureLevel[_]
  private_subnets := data.rfc1819Subnets[_]

  total_addresses := { ipaddress | ipaddress := ingressWithExposureLevel.hostnames[_] }
  private_addresses := { ipaddress | ipaddress := ingressWithExposureLevel.hostnames[_]; net.cidr_contains(private_subnets, ipaddress) }

  count(private_addresses) == count(total_addresses)
}

ingressesResolvingToPublicIPs[ingressWithExposureLevel] {
  ingressWithExposureLevel := ingressesWithExposureLevel[_]
  not ingressesResolvingToOnlyPrivateIPs[ingressWithExposureLevel]
}

# Just trying to find a better way to do this than above.. would love to get the public hostname and its corresponding IP if possible
# but this returns all of the ingresses
ingressesResolvingToPublicIPs2[ingressWithExposureLevel] {
  ingressWithExposureLevel := ingressesWithExposureLevel[_]
  private_subnets := data.rfc1819Subnets[_]

  public_addresses := { ipaddress | ipaddress := ingressWithExposureLevel.hostnames[_]; not net.cidr_contains(private_subnets, ipaddress) }
  count(public_addresses) > 0
}

violations[msg] {
  ingressResolvingToPublicIP := ingressesResolvingToPublicIPs[_]
  not ingressResolvingToPublicIP.exposureLevel == "internet"

  # TODO: Need to figure how to get the hostname/ipaddress in here
  # couldnt we do:  public_addresses := { ipaddress | ipaddress := ingressWithExposureLevel.hostnames[_]; not net.cidr_contains(private_subnets, ipaddress)
  # count(public_addresses) > 0 ?   maybe we could then keep the public_addresses and pass it into the violation
  msg := sprintf("Ingresses with at least one hostname that resolves to a public IP must have an annotation indicating that its exposure level is 'internet'. ingress=%s/%s", [ingressResolvingToPublicIP.namespace, ingressResolvingToPublicIP.name])
}
