package exposure

# The default exposure level for Pods is intranet
# The default exposure level for ClusterIP services is cluster
# The default exposure level for NodePort services is intranet
# The default exposure level for LoadBalancer services with a private IP is intranet
# The ONLY allowed exposure level for LoadBalancer services with a public IP is internet (firewalls could restrict access but things should only have a public IP for they are intended to be reached publically)

# TODO: how can I set a default exposure level for a pod or service that doesnt have one? for now I have to set the defaults explicitly.  I came across this but am not sure how to use it https://stackoverflow.com/questions/59688239/how-to-do-a-b-in-rego.

# TODO: check for LoadBalancers with public IPs that have the exposure level set to anything other than internet.. its an obvious violation

# Pods should always have an exposure level of cluster, intranet, or internet




# This rule is used to join Services to their target Pods based on label selectors
servicePods[servicePod] {
  service := data.services[_]
  pod := data.pods[_]

  # Extract the service selector labels as a set and then extract the subset of the pods labels that match the service selector labels
  serviceLabelSet := { { x: service.selector[x] } | service.selector[x] }
  podLabelFilteredSet := { { x: pod.labels[x] } | pod.labels[x]; pod.labels[x] == service.selector[x] }

  # Check to make sure that the service actually points at the pods
  service.namespace == pod.namespace
  serviceLabelSet == podLabelFilteredSet

  servicePod := { "service": service, "pod": pod }
}

# This detects services that have an exposure level of internet but point to pods with an exposure level that is either intranet or cluster
violations[msg] {
  servicePod := servicePods[_]
  service := servicePod.service
  pod := servicePod.pod

  service.annotations.exposure == "internet"
  pod.annotations.exposure != "internet"

  msg := sprintf("Services with an exposure level of %s must not point to pods that have an exposure level of %s service=%s/%s pod=%s/%s", [service.annotations.exposure, pod.annotations.exposure, service.namespace, service.name, pod.namespace, pod.name])
}

# This detects services that have an exposure level of intranet but point to pods with an exposure level that is cluster
violations[msg] {
  servicePod := servicePods[_]
  service := servicePod.service
  pod := servicePod.pod

  service.annotations.exposure == "intranet"
  pod.annotations.exposure == "cluster"

  msg := sprintf("Services with an exposure level of %s must not point to pods that have an exposure level of %s service=%s/%s pod=%s/%s", [service.annotations.exposure, pod.annotations.exposure, service.namespace, service.name, pod.namespace, pod.name])
}
