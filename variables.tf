variable "environment" {
  type        = string
  description = "The environment name"
  default     = "dev"
}

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

variable "project_name_override" {
  type        = string
  description = "Override project name prefix used in all the resources"
  default     = ""
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

variable "min_kubernetes_version" {
  type        = string
  description = "The Kubernetes MINIMUM version of the masters. GCP can perform upgrades, there is no max_version field. If set to 'latest' it will pull latest available version in the selected region."
  default     = "latest"
}

variable "gke_instance_type" {
  type        = string
  description = "The worker instance type"
  default     = "n1-standard-2"
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

variable "gke_max_surge" {
  type        = string
  description = "The number of additional nodes that can be added to the node pool during an upgrade. Increasing max_surge raises the number of nodes that can be upgraded simultaneously. Can be set to 0 or greater."
  default     = 1
}

variable "gke_max_unavailable" {
  type        = string
  description = "The number of nodes that can be simultaneously unavailable during an upgrade. Increasing max_unavailable raises the number of nodes that can be upgraded in parallel. Can be set to 0 or greater."
  default     = 0
}

variable "node_auto_repair" {
  type        = bool
  description = "Whether the nodes will be automatically repaired"
  default     = true
}

variable "node_auto_upgrade" {
  type        = bool
  description = "Whether the nodes will be automatically upgraded"
  default     = true
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

variable "kubelet_config" {
  type = object({
    cpu_manager_policy   = string,
    cpu_cfs_quota        = bool,
    cpu_cfs_quota_period = string
  })
  description = "Node kubelet configuration. Possible values can be found at https://cloud.google.com/kubernetes-engine/docs/how-to/node-system-config#kubelet-options"
  default     = null
}

variable "google_compute_firewall_name" {
  type        = string
  description = "The name of the firewall rule to be created"
  default     = "istio-discovery-allow-firewall"
}

variable "deletion_protection" {
  type        = bool
  description = "Whether to enable deletion protection on the cluster"
  default     = true
}

variable "service_account_id" {
  type        = string
  description = "The service account id to use for the GKE cluster"
  default     = null
}
variable "logging_service" {
  type        = string
  description = "The logging service that the cluster should write logs to. Available options include logging.googleapis.com, logging.googleapis.com/kubernetes (beta), and none"
  default     = "logging.googleapis.com/kubernetes"

  validation {
    condition     = contains(["logging.googleapis.com", "logging.googleapis.com/kubernetes", "none"], var.logging_service)
    error_message = "The logging_service must be one of 'logging.googleapis.com', 'logging.googleapis.com/kubernetes', or 'none'."
  }
}

variable "monitoring_service" {
  type        = string
  description = "The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none"
  default     = "monitoring.googleapis.com/kubernetes"

  validation {
    condition     = contains(["monitoring.googleapis.com", "monitoring.googleapis.com/kubernetes", "none"], var.monitoring_service)
    error_message = "The monitoring_service must be one of 'monitoring.googleapis.com', 'monitoring.googleapis.com/kubernetes', or 'none'."
  }
}

variable "enable_cluster_autoscaler" {
  type        = bool
  description = "Whether to enable cluster autoscaler"
  default     = false
}

variable "autoscaling_profile" {
  type        = string
  description = "The autoscaling profile to use. Valid values are: balanced, cost, performance. Default: balanced"
  default     = "BALANCED"

  validation {
    condition     = contains(["BALANCED", "OPTIMIZE_UTILIZATION"], upper(var.autoscaling_profile))
    error_message = "The autoscaling_profile must be one of 'BALANCED' or 'OPTIMIZE_UTILIZATION'."
  }
}

variable "cluster_autoscaler_cpu_min" {
  type        = number
  description = "Minimum number of CPUs in the cluster autoscaler"
  default     = 1
}

variable "cluster_autoscaler_cpu_max" {
  type        = number
  description = "Maximum number of CPUs in the cluster autoscaler"
  default     = 10
}
variable "cluster_autoscaler_memory_min_gb" {
  type        = number
  description = "Minimum amount of memory in the cluster autoscaler (in GB)"
  default     = 1
}
variable "cluster_autoscaler_memory_max_gb" {
  type        = number
  description = "Maximum amount of memory in the cluster autoscaler (in GB)"
  default     = 10
}

variable "enable_vpa" {
  type        = bool
  description = "Whether to enable vertical pod autoscaler"
  default     = false
}
