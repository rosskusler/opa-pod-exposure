package exposure

ingressExposedPods[ingressExposedPod] {
  igcService := data.services[_]
  igcPod := data.pods[_]
  ig := data.ingresses[_]
  appService := data.services[_]
  appPod := data.pods[_]

  igcService.namespace == igcPod.namespace
  # TODO: Smarter mapping from selector or labels
  igcService.selector == igcPod.labels 

  igcPod.ingressClass == ig.ingressClass

  # Map the ingress to the appService
  ig.namespace == appService.namespace
  ig.serviceName == appService.name

  # Map the appSerivce to the appPod
  appService.namespace == appPod.namespace
  appService.selector == appPod.labels

  ingressExposedPod := {
    "igcService": igcService,
    "igcPod": igcPod,
    "ig": ig,
    "appService": appService,
    "appPod": appPod
  }
}
