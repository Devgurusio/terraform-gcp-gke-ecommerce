# Encrypted ETCD Regional Cluster
The cluster will have the following features:
* Regional cluster using 3 zone
* Latest kubernetes version available
* Unspecified release channel suscription
* Node pool with `n1-standard-1` instances
* Max instances per zone: 2
* Master ETCD cluster encryption enabled
* Nodes boot volumes encryption disabled
* Network policies disabled
* Metrics server deployed. This means HPAs will be able to autoscale
