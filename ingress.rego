package exposure

# TODO: right now we're ignoring the exposure on the services... is that actually necessary?  Yeah because we need to block services w/ a publicIP but isnt marked internet
# TODO: where do we look at the default exposure at the service level (it will differ based on type!)
# TODO: I might be missing possible errors by doing the full joins.. I wont see issues with the igcExposure until the ingress actually has a appPod.  Smaller joins would catch it though956179


ingressExposedPods[ingressExposedPod] {
  igcService := data.services[_]
  igcPod := data.pods[_]
  ig := data.ingresses[_]
  appService := data.services[_]
  appPod := data.pods[_]

  # Join the ingress controller service to the ingress controller pod
  igcServiceLabelSet := { { x: igcService.selector[x] } | igcService.selector[x] }
  igcPodLabelFilteredSet := { { x: igcPod.labels[x] } | igcPod.labels[x]; igcPod.labels[x] == igcService.selector[x] }
  igcService.namespace == igcPod.namespace
  igcServiceLabelSet == igcPodLabelFilteredSet

  # Join the ingress controller's ingressClass  pod to the ingress's ingressClass
  igcPod.ingressClass == ig.ingressClass

  # Join the ingress to the appService
  ig.namespace == appService.namespace
  ig.serviceName == appService.name

  # Join the appSerivce to the appPod
  appServiceLabelSet := { { x: appService.selector[x] } | appService.selector[x] }
  appPodLabelFilteredSet := { { x: appPod.labels[x] } | appPod.labels[x]; appPod.labels[x] == appService.selector[x] }
  appService.namespace == appPod.namespace
  appServiceLabelSet == appPodLabelFilteredSet

  # Combine the objects into an aggregate object
  ingressExposedPod := {
    "igcService": igcService,
    "igcPod": igcPod,
    "ig": ig,
    "appService": appService,
    "appPod": appPod,

    "igcServiceExposure": getServiceExposure(igcService),
    "igcPodExposure": getPodExposure(igcPod),
    "appServiceExposure": getServiceExposure(appPod),
    "appPodExposure": getPodExposure(appPod)
  }
}

# If the appPodExposure is internet, nothing else really matters including
validExposure[ingressExposedPod] {
  ingressExposedPod := ingressExposedPods[_]
  ingressExposedPod.appPodExposure == "internet"
}

# If the igcPodExposure is cluster it doesnt matter what the appPodExposure is
validExposure[ingressExposedPod] {
  ingressExposedPod := ingressExposedPods[_]
  ingressExposedPod.igcPodExposure == "cluster"
}

# If the appPodExposure is intranet the igcPodExposure can be intranet or cluster (but we have a rule for matching cluster)
validExposure[ingressExposedPod] {
  ingressExposedPod := ingressExposedPods[_]
  ingressExposedPod.appPodExposure == "intranet"
  ingressExposedPod.igcPodExposure == "intranet"
}

invalidExposure[ingressExposedPod] {
  ingressExposedPod := ingressExposedPods[_]
  not validExposure[ingressExposedPod]
}


violations[msg] {
  ingressExposedPod := invalidExposure[_]

  msg := sprintf("Pods with an exposure level of '%s' cannot be referenced by ingress controllers with an exposure level of '%s' appPod=%s/%s igcPod=%s/%s", [ingressExposedPod.appPodExposure, ingressExposedPod.igcPodExposure, ingressExposedPod.appPod.namespace, ingressExposedPod.appPod.name, ingressExposedPod.igcPod.namespace, ingressExposedPod.igcPod.name])
}

