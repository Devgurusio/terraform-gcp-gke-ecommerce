variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
  default     = "playground-s-11-a4caf2"
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
  default     = "us-central1"
}

variable "zones" {
  type        = list(string)
  description = "The zone to host the cluster in (required if is a zonal cluster)"
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Master Nodes"
  default     = "172.16.0.0/28"
}

variable "pods_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Kubernetes Pods"
  default     = "192.168.0.0/18"
}

variable "services_ipv4_cidr_block" {
  type        = string
  description = "IPv4 CIDR Block for Kubernetes services"
  default     = "192.168.64.0/18"
}

variable "subnet_ip_cidr_range" {
  type        = string
  description = "IPv4 CIDR Block for SubNetwork"
  default     = "10.0.0.0/17"
}
