List of things to improve about this 

* Add tests!!!

* True the schema up to what actual Services/Pods/Ingress look like. For instance, how do we get the ingressClass from an Ingress controller? This is probably ingress controller specific but we could code something up that extracts the default ingress class from the nginx-ingress controller. In other cases we could require that the ingress class is specified as an annotation. Also I dont think the ingress hostname list is named correctly

* Get the logic for determining which ingress controller has a hostname resolving to a public IP working properly

* Find some way to actually do DNS lookups of ingress hostnames

* Extract the mapping of hostname -> ip into a different table (so the ingress object should just contain an array of hostnames)

* Get the violation for ingresses that point to public IPs to actually show the hostname and public IP

* Add support for hostnames that resolve to multiple IPs.. what if ANY of them are public?

* Restructure the data and input so that this could actually be used as admission controller logic and not just statically reviewing a real cluster

* Maybe data.json should just be an array of objects that have a Kind

* labels and annotations are under metadata

* ingress hostnames are in spec.rules[\_].hostname and also spec.tls.hosts[\_]

* should we also look at ingress.status.loadBalancer.ingress[\_].ip to see if it is public? Not sure if this is really necessary

* the loadbalancer.type is actually under spec

* the loadbalancer selector is under spec

* the loadbalancer externalIP is actually spec.loadBalancerIP. Or even better: status.loadBalancer.ingress[_].ip
