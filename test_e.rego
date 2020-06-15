package exposure

test_pod_exposure_ok {
  not violations
  with data.services as [
    {
      "name": "svc_cip_for_pod",
      "note": "This is a simple ClusterIP service that points to Pod",
      "namespace": "test",
      "type": "ClusterIP",
      "selector": {
        "app": "test_pod_1"
      },
      "annotations": {
        "exposure": "intranet"
      }
    }
  ]

  with data.pods as [ 
    {
      "name": "test_pod_1",
      "namespace": "test",
      "labels": {
        "app": "test_pod_1"
      }
    }
  ]
}




test_pod_exposure {
  violations
  with data.services as [
    {
      "name": "svc_cip_for_pod",
      "note": "This is a simple ClusterIP service that points to Pod",
      "namespace": "test",
      "type": "ClusterIP",
      "selector": {
        "app": "test_pod_1"
      },
      "annotations": {
        "exposure": "internet"
      }
    }
  ]

  with data.pods as [ 
    {
      "name": "test_pod_1",
      "namespace": "test",
      "labels": {
        "app": "test_pod_1"
      }
    }
  ]
}
