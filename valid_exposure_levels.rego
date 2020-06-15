package exposure

valid_pod_exposure_level[pod] {
  pod := data.pods[_]
  pod.annotations.exposure == "internet"
}

valid_pod_exposure_level[pod] {
  pod := data.pods[_]
  pod.annotations.exposure == "intranet"
}

valid_pod_exposure_level[pod] {
  pod := data.pods[_]
  pod.annotations.exposure == "cluster"
}

# BUG: if an exposure level isnt set for a pod, OPA doesnt trigger a violation.  This rule only works if an exposure level is set to an unknown value
violations[msg] {
  pod := data.pods[_]
  not valid_pod_exposure_level[pod]
  msg := sprintf("Pod doesnt have a valid exposure level %s/%s exposure=%s", [pod.namespace, pod.name, pod.annotations.exposure])
}

valid_service_exposure_level[service] {
  service := data.services[_]
  service.annotations.exposure == "internet"
}

valid_service_exposure_level[service] {
  service := data.services[_]
  service.annotations.exposure == "intranet"
}

valid_service_exposure_level[service] {
  service := data.services[_]
  service.annotations.exposure == "cluster"
}

# BUG: if an exposure level isnt set for a service, OPA doesnt trigger a violation.  This rule only works if an exposure level is set to an unknown value
violations[msg] {
  service := data.services[_]
  not valid_service_exposure_level[service]
  msg := sprintf("Service doesnt have a valid exposure level %s/%s exposure=%s", [service.namespace, service.name, service.annotations.exposure])
}
