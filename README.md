This implements a policy that attempts to prevent applications which are only supposed to be accessed from an intranet or within a kubernetes cluster from being reachable over the internet.

The ONLY allowed exposure level for LoadBalancer services with a public IP is 'internet'.  Yes it's theoretically possible for network firewalls to restrict access but IMO if something shouldnt be accessed from the public internet it should not have a public IP.

TODO: add examples of how the annotations on Services/Pods/Ingresses should look

TODO: write up a statement describing the problem that this solves.. maybe point to a blog article

```
exposureLevels := {
  "cluster": 1,
  "intranet": 2,
  "internet": 3
}
```
