package exposure

exposureLevels := {
  "cluster": 1,
  "intranet": 2,
  "internet": 3
}

# If the object has an exposure annotation, return it
getExposureLevel(obj) = exposureLevel {
  exposureLevel := obj.annotations.exposure
}

# If the object doesnt have an exposure annotation, it defaults to intranet
getExposureLevel(obj) = exposureLevel {
  not obj.annotations.exposure
  exposureLevel := "intranet"
}

# This returns a list of pods that dont have an invalidd exposure annotation, with the annotation in the exposureLevel field
podsWithExposureLevel[result] {
  pod := data.pods[_]
  exposureLevel = getExposureLevel(pod)
  exposureLevels[exposureLevel]
  result := merge(pod, { "exposureLevel": exposureLevel })
}

# This returns a list of services that dont have an invalid exposure annotation, with the annotation in the exposureLevel field
servicesWithExposureLevel[result] {
  service := data.services[_]
  exposureLevel = getExposureLevel(service)
  exposureLevels[exposureLevel]
  result := merge(service, { "exposureLevel": exposureLevel })
}

# This returns a list of ingresses that dont have an invalid exposure annotation, with the annotation in the exposureLevel field
ingressesWithExposureLevel[result] {
  ingress := data.ingresses[_]
  exposureLevel = getExposureLevel(ingress)
  exposureLevels[exposureLevel]
  result := merge(ingress, { "exposureLevel": exposureLevel })
}

# If the pod specifies an exposure level it needs to be valid
violations[msg] {
  pod := data.pods[_]
  exposureLevel = getExposureLevel(pod)
  not exposureLevels[exposureLevel]

  msg := sprintf("Pod has invalid exposure level '%s' pod=%s/%s", [exposureLevel, pod.namespace, pod.name])
}

# If the service specifies an exposure level it needs to be valid
violations[msg] {
  service := data.services[_]
  exposureLevel := getExposureLevel(service)
  not exposureLevels[exposureLevel]

  msg := sprintf("Service has invalid exposure level '%s' service=%s/%s", [exposureLevel, service.namespace, service.name])
}

# If the ingress specifies an exposure level it needs to be valid
violations[msg] {
  ingress := data.ingresses[_]
  exposureLevel := getExposureLevel(ingress)
  not exposureLevels[exposureLevel]

  msg := sprintf("Ingress has invalid exposure level '%s' ingress=%s/%s", [exposureLevel, ingress.namespace, ingress.name])
}
