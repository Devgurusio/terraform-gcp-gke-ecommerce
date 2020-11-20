# Simple Zonal Cluster
The cluster will have the following features:
* Zonal cluster using 1 zone
* Latest kubernetes version available
* Unspecified release channel suscription
* Node pool with `n1-standard-1` instances
* Max instances per zone: 2
* Master ETCD cluster encryption disabled
* Nodes boot volumes encryption disabled
* Network policies disabled
* Metrics server deployed. This means HPAs will be able to autoscale
