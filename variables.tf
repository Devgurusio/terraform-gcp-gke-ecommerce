variable "environment" {
  type        = string
  description = "The environment name"
  default     = "dev"
}

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

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
  description = "The region to host the cluster in"
  default     = null
}

variable "zones" {
  type        = list(string)
  description = "The zone to host the cluster in (required if is a zonal cluster)"
  default     = []
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Master Nodes"
  default     = "10.0.1.0/28"
}

variable "cluster_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Kubernetes Pods"
  default     = "10.13.0.0/20"
}

variable "services_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Kubernetes services"
  default     = "10.13.16.0/20"
}

variable "subnet_ip_cidr_range" {
  type        = string
  description = "IPv4 CIDR Block for SubNetwork"
  default     = "192.168.16.0/20"
}

variable "nat_ip_count" {
  type        = number
  description = "The number of NAT IPs"
  default     = 1
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  default     = "latest"
}

variable "node_version" {
  type        = string
  description = "The Kubernetes version of the node pools. Defaults kubernetes_version (master) variable and can be overridden for individual node pools by setting the `version` key on them. Must be empyty or set the same as master at cluster creation."
  default     = ""
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
  default     = 20
}

variable "gke_preemptible" {
  type        = bool
  description = "GKE Preemtible nodes"
  default     = true
}

variable "gke_auto_min_count" {
  type        = number
  description = "The minimum number of VMs in the pool per group (zones) as it is a regional cluster"
  default     = 1
}

variable "gke_auto_max_count" {
  type        = number
  description = "The maximum number of VMs in the pool per zone (zones) as it is a regioinal cluster"
  default     = 2
}

variable "oauth_scopes" {
  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/taskqueue",
    "https://www.googleapis.com/auth/sqlservice.admin",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/pubsub",
    "https://www.googleapis.com/auth/cloud_debugger",
  ]
}


variable "istio_config" {
  type        = bool
  description = "Enable istio addon"
  default     = false
}