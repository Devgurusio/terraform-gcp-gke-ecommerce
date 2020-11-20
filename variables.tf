variable "environment" {
  type        = string
  description = "The environment name"
  default     = "dev"
}

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

## K8s related settings
variable "cluster_name_suffix" {
  type        = string
  description = "A suffix to append to the default cluster name"
  default     = ""
}

variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
  default     = true
}

variable "region" {
  type        = string
  description = "The region to host the cluster in. Default: us-central1"
  default     = "us-central1"
}

variable "zones" {
  type        = list(string)
  description = "The zone to host the cluster in (required if is a zonal cluster)"
  default     = []
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Master Nodes"
  default     = "172.16.0.0/28"
}

variable "cluster_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Kubernetes Pods"
  default     = "192.168.0.0/18"
}

variable "services_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Kubernetes services"
  default     = "192.168.64.0/18"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  default     = "latest"
}

variable "gke_instance_type" {
  type        = string
  description = "The worker instance type"
  default     = "n1-standard-1"
}

variable "daily_maintenance_window_start" {
  type        = string
  description = "Time window specified for daily maintenance operations in RFC3339 format"
  default     = "03:00"
}

variable "node_pool_disk_size" {
  type        = number
  description = "Disk Size for GKE Nodes"
  default     = 40
}

variable "node_pool_disk_type" {
  type        = string
  description = "Disk type for GKE nodes. Available values: pd-stadard, pd-ssd.Default: pd-standard"
  default     = "pd-ssd"
}

variable "gke_preemptible" {
  type        = bool
  description = "GKE Preemtible nodes"
  default     = true
}

variable "gke_initial_node_count" {
  type        = number
  description = "The initial number of VMs in the pool per group (zones) as it is a regional cluster"
  default     = 1
}

variable "gke_auto_min_count" {
  type        = number
  description = "The minimum number of VMs in the pool per group (zones) as it is a regional cluster"
  default     = 0
}

variable "gke_auto_max_count" {
  type        = number
  description = "The maximum number of VMs in the pool per zone (zones) as it is a regional cluster"
  default     = 2
}

variable "release_channel" {
  type        = string
  description = "The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `UNSPECIFIED`."
  default     = "UNSPECIFIED"
}

variable "enable_hpa" {
  type        = bool
  description = "Toggles horizontal pod autoscaling addon. Default: true"
  default     = true
}

variable "enable_netpol" {
  type        = bool
  description = "Toggles network policies enforcement feature. Default: false"
  default     = false
}

variable "netpol_provider" {
  type        = string
  description = "Sets the network policy provider. Default: CALICO"
  default     = "CALICO"
}

# Network related settings
variable "subnet_ip_cidr_range" {
  type        = string
  description = "IPv4 CIDR Block for Subnetwork"
  default     = "10.0.0.0/17"
}

variable "nat_ip_count" {
  type        = number
  description = "The number of NAT IPs"
  default     = 1
}

variable "min_ports_per_vm" {
  type        = string
  description = "Max number of concurrent outgoing request to IP:PORT_PROTOCOL per VM"
  default     = "8192"
}

variable "tcp_transitory_idle_timeout_sec" {
  type        = string
  description = "The tcp trans idle timeout in sec used by the nat gateway"
  default     = "30"
}

variable "tcp_established_idle_timeout_sec" {
  type        = string
  description = "The tcp established idle timeout in sec used by the nat gateway"
  default     = "1200"
}

variable "udp_idle_timeout_sec" {
  type        = string
  description = "Timeout (in seconds) for UDP connections. Defaults to 30s if not set."
  default     = "30"
}

variable "icmp_idle_timeout_sec" {
  type        = string
  description = "Timeout (in seconds) for ICMP connections. Defaults to 30s if not set."
  default     = "30"
}

variable "database_encryption" {
  type        = object({ state = string, key_name = string })
  description = "Application-layer Secrets Encryption settings. The object format is {state = string, key_name = string}. Valid values of state are: \"ENCRYPTED\"; \"DECRYPTED\". key_name is the name of a CloudKMS key."
  default = {
    state    = "DECRYPTED"
    key_name = ""
  }
}

variable "boot_disk_kms_key" {
  type        = string
  description = "CloudKMS key_name to use to encrypt the nodes boot disk. Default: null (encryption disabled)"
  default     = null
}
