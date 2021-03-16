[![GitHub Super-Linter](https://github.com/Devgurusio/terraform-gcp-gke-ecommerce/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

# Google Kubernetes Engine (GKE)

This is an opinionated terraform module to bootstrap a GKE Cluster using Terraform. Based on our
needs and following
[GKE security best practices](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster),
we've enabled/disabled some features by default.

Features enabled:

* Default node pool removed
* Logging and Monitoring using Cloud Operations for GKE
* GKE Shielded nodes (with secure boot enabled)
* Workload identity
* VPC Native cluster
* Storage classes using CSI driver
* Prevent cluster destroy
* Updatable nodes (new node pool created before destroying the old one)
* non-default SA for nodes
* Usage of containerd as runtime

Features disabled:

* Basic auth for API server
* Client certificate issuing for API server
* Istio addon


## Usage

### Usage example

```hcl
variable "project_id" {
  default = "my-project"
}

module "gke-ecommerce" {
  source  = "Devgurusio/gke-ecommerce/gcp"
  version = "1.2.3"

  project_id = var.project_id
}

provider "google" {
  project_id = var.project_id
}

provider "google-beta" {
  project_id = var.project_id
}
```

### Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 0.14 |

### Providers

| Name        | Version  |
| ----------- | -------- |
| google      | >= 3.60  |
| google-beta | >= 3.60  |
| random      | >= 3.1.0 |

### Inputs

| Name                             | Description                                                                                                                                                                                              | Type                                          | Default                                            | Required |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- | -------------------------------------------------- | -------- |
| boot_disk_kms_key                | CloudKMS key_name to use to encrypt the nodes boot disk. Default: null (encryption disabled)                                                                                                             | string                                        | null                                               | no       |
| cluster_ipv4_cidr_block          | IPv4 CIDR Block for Kubernetes Pods                                                                                                                                                                      | string                                        | 192.168.0.0/18                                     | no       |
| cluster_name_suffix              | A suffix to append to the default cluster name                                                                                                                                                           | string                                        | ""                                                 | no       |
| daily_maintenance_window_start   | Time window specified for daily maintenance operations in RFC3339 format                                                                                                                                 | string                                        | 03:00                                              | no       |
| database_encryption              | Application-layer Secrets Encryption settings. The object format is {state = string, key_name = string}. Valid values of state are: \"ENCRYPTED\"; \"DECRYPTED\". key_name is the name of a CloudKMS key | object({ state = string, key_name = string }) | `{ state = "DECRYPTED", key_name = "" }`           | no       |
| enable_hpa                       | Toggles horizontal pod autoscaling addon                                                                                                                                                                 | bool                                          | true                                               | no       |
| enable_netpol                    | Toggles network policies enforcement feature                                                                                                                                                             | bool                                          | false                                              | no       |
| environment                      | The environment name                                                                                                                                                                                     | string                                        | dev                                                | no       |
| gke_auto_max_count               | The maximum number of VMs in the pool per zone                                                                                                                                                           | number                                        | 2                                                  | no       |
| gke_auto_min_count               | The minimum number of VMs in the pool per zone                                                                                                                                                           | number                                        | 0                                                  | no       |
| gke_initial_node_count           | The initial number of VMs in the pool per zone                                                                                                                                                           | number                                        | 1                                                  | no       |
| gke_instance_type                | Workers instance type                                                                                                                                                                                    | string                                        | n1-standard-2                                      | no       |
| gke_preemptible                  | Use preemtible instances for the node pool                                                                                                                                                               | bool                                          | true                                               | no       |
| icmp_idle_timeout_sec            | Timeout (in seconds) for ICMP connections                                                                                                                                                                | string                                        | "30"                                               | no       |
| master_ipv4_cidr_block           | IPv4 CIDR Block for Master Nodes                                                                                                                                                                         | string                                        | 172.16.0.0/28                                      | no       |
| min_kubernetes_version           | The Kubernetes MINIMUM version of the masters. GCP can perform upgrades, there is no max_version field. If set to 'latest' it will pull latest available version in the selected region                  | string                                        | latest                                             | no       |
| min_ports_per_vm                 | Max number of concurrent outgoing request to IP:PORT_PROTOCOL per VM                                                                                                                                     | number                                        | 8192                                               | no       |
| nat_ip_count                     | The number of NAT IPs                                                                                                                                                                                    | number                                        | 1                                                  | no       |
| netpol_provider                  | Sets the network policy provider                                                                                                                                                                         | string                                        | CALICO                                             | no       |
| node_auto_upgrade                | Whether the nodes will be automatically repaired                                                                                                                                                         | bool                                          | true                                               | no       |
| node_auto_repair                 | Whether the nodes will be automatically upgraded                                                                                                                                                         | bool                                          | true                                               | no       |
| node_pool_disk_size              | Disk Size for GKE Nodes                                                                                                                                                                                  | number                                        | 40                                                 | no       |
| node_pool_disk_type              | Disk type for GKE nodes. Available values: pd-stadard, pd-ssd.                                                                                                                                           | string                                        | pd-ssd                                             | no       |
| project_id                       | The project ID to host the cluster in                                                                                                                                                                    | string                                        | null                                               | yes      |
| project_name_override            | Override project name prefix used in all the resources                                                                                                                                                   | string                                        | ""                                                 | no       |
| regional                         | Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)                                                                                | bool                                          | true                                               | no       |
| region                           | The region to host the cluster in                                                                                                                                                                        | string                                        | us-central1                                        | no       |
| release_channel                  | The release channel of this cluster. Allowed values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`                                                                                                   | string                                        | UNSPECIFIED                                        | no       |
| services_ipv4_cidr_block         | IPv4 CIDR Block for Kubernetes services                                                                                                                                                                  | string                                        | 192.168.64.0/18                                    | no       |
| subnet_ip_cidr_range             | IPv4 CIDR Block for Subnetwork                                                                                                                                                                           | string                                        | 10.0.0.0/17                                        | no       |
| tcp_established_idle_timeout_sec | The tcp established idle timeout in sec used by the nat gateway                                                                                                                                          | string                                        | "1200"                                             | no       |
| tcp_transitory_idle_timeout_sec  | The tcp trans idle timeout in sec used by the nat gateway                                                                                                                                                | string                                        | "30"                                               | no       |
| udp_idle_timeout_sec             | Timeout (in seconds) for UDP connections                                                                                                                                                                 | string                                        | "30"                                               | no       |
| zones                            | The zone to host the cluster in (required if is a zonal cluster)                                                                                                                                         | list(string)                                  | []                                                 | no       |

### Outputs

| Name                     | Description                  |
| ------------------------ | ---------------------------- |
| google_container_cluster | GKE cluster name             |
| k8s_ingress_ip           | API server public IP address |
| nat_address              | List of NAT addresses        |
| network_name             | Network name                 |
| network_self_link        | Network selflink             |
| subnetwork_name          | Subnetwork name              |

### Service Account permissions

To be able to bootstrap the cluster please ensure that the GCP Service Account have at least these
roles:

* roles/storage.objectAdmin (needed if you use GCS as backend)
* roles/container.admin
* roles/compute.admin
* roles/cloudkms.admin
* roles/iam.serviceAccountAdmin
* roles/iam.serviceAccountUser
* roles/iam.securityAdmin

## Development

Please follow the [contributing guidelines](CONTRIBUTING.md)
