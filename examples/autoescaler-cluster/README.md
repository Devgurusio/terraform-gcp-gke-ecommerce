# Simple Zonal Cluster
The cluster will have the following features:
* Latest kubernetes version available
* Unspecified release channel suscription
* Node pool with `n1-standard-1` instances
* Master ETCD cluster encryption disabled
* Nodes boot volumes encryption disabled
* Network policies disabled
* Metrics server deployed. This means HPAs will be able to autoscale
* Autoscaler enabled on the cluster
* Vertical pod autoscaler enabled on the cluster
