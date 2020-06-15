package exposure

exposureLevels := {
  "cluster": 1,
  "intranet": 2,
  "internet": 3
}

getPodExposure(pod) = exposure {
  exposure := pod.annotations.exposure
}

getPodExposure(pod) = exposure {
  not pod.annotations.exposure
  exposure := "intranet"
}

getServiceExposure(service) = exposure {
  exposure := service.annotations.exposure
}

getServiceExposure(service) = exposure {
  not service.annotations.exposure
  exposure := "intranet"
}

violations[msg] {
  pod := data.pods[_]
  podExposure = getPodExposure(pod)
  not exposureLevels[podExposure]

  msg := sprintf("Pod has invalid exposure level '%s' pod=%s/%s", [podExposure, pod.namespace, pod.name])
}
