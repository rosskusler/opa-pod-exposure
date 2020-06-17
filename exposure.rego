package exposure

# The ONLY allowed exposure level for LoadBalancer services with a public IP is internet (firewalls could restrict access but things should only have a public IP for they are intended to be reached publically)

# TODO: check for LoadBalancers with public IPs that have the exposure level set to anything other than internet.. its an obvious violation

# In the real world the ingress controll pods dont have an ingressClass object, AFAIK.. it's kind of contrived here

# This rule is used to join Services to their target Pods based on label selectors
servicePodMaps[servicePodMap] {
  service := servicesWithExposureLevel[_]
  pod := podsWithExposureLevel[_]

  # Extract the service selector labels as a set and then extract the subset of the pods labels that match the service selector labels
  serviceLabelSet := { { x: service.selector[x] } | service.selector[x] }
  podLabelFilteredSet := { { x: pod.labels[x] } | pod.labels[x]; pod.labels[x] == service.selector[x] }

  # Perform the join based on the namespace and label selector
  service.namespace == pod.namespace
  serviceLabelSet == podLabelFilteredSet

  servicePodMap := { "service": service, "pod": pod }
}

# This rule is used to join Ingress objects to their target Services
ingressServiceMaps[ingressServiceMap] {
  ingress := ingressesWithExposureLevel[_]
  service := servicesWithExposureLevel[_]

  # Perform the join based on the namespace and service name
  ingress.namespace == service.namespace
  ingress.serviceName == service.name

  ingressServiceMap := { "ingress": ingress, "service": service }
}

# This rule is used to join Ingress controller pods to Ingress objects
igcPodIngressMaps[igcPodIngressMap] {
  igcPod := podsWithExposureLevel[_]
  ingress := ingressesWithExposureLevel[_]

  # Perform the join based on the ingress classes of the controller pod and ingress
  igcPod.ingressClass == ingress.ingressClass

  igcPodIngressMap := { "igcPod": igcPod, "ingress": ingress }
}

# This detects services that have an exposure level greater than the pods that they point to (Ie service=internet -> pod=intranet)
violations[msg] {
  servicePodMap := servicePodMaps[_]
  service := servicePodMap.service
  pod := servicePodMap.pod

  exposureLevels[service.exposureLevel] > exposureLevels[pod.exposureLevel]

  msg := sprintf("Services with an exposure level of '%s' must not point to pods that have an exposure level of '%s' service=%s/%s pod=%s/%s", [service.exposureLevel, pod.exposureLevel, service.namespace, service.name, pod.namespace, pod.name])
}

# This detects ingresses that have an exposure level greater than the service that they point to (Ie ingress=internet -> service=cluster)
violations[msg] {
  ingressServiceMap := ingressServiceMaps[_]
  ingress := ingressServiceMap.ingress
  service := ingressServiceMap.service

  exposureLevels[ingress.exposureLevel] > exposureLevels[service.exposureLevel]

  msg := sprintf("Ingresses with an exposure level of '%s' must not point to services that have an exposure level of '%s' ingress=%s/%s service=%s/%s", [ingress.exposureLevel, service.exposureLevel, ingress.namespace, ingress.name, service.namespace, service.name])
}

# This detects ingress controller pods that have an exposure level greater than the ingresses that they contain to (Ie igc=internet and ingress=intranet)
violations[msg] {
  igcPodIngressMap := igcPodIngressMaps[_]
  igcPod := igcPodIngressMap.igcPod
  ingress := igcPodIngressMap.ingress

  exposureLevels[igcPod.exposureLevel] > exposureLevels[ingress.exposureLevel]
 
  msg := sprintf("Ingress controllers with an exposure level of '%s' must not contain any ingress with an exposure level of '%s' ingressController=%s/%s ingress=%s/%s", [igcPod.exposureLevel, ingress.exposureLevel, igcPod.namespace, igcPod.name, ingress.namespace, ingress.name])
}
