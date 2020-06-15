package exposure

get_pod_exposure(pod) = exposure {
  exposure := pod.annotations.exposure
}

get_pod_exposure(pod) = exposure {
  not pod.annotations.exposure
  exposure := "global"
}

pods_with_exposure_level[podWithExposure] {
  pod := data.pods[_]
  exposureLevel := get_pod_exposure(pod)
  podWithExposure :=  { "pod": pod, "exposure": exposureLevel }
}
