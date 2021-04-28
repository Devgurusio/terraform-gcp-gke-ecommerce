variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in. Default: us-central1"
  default     = "us-central1"
}

variable "zones" {
  type        = list(string)
  description = "When regional cluster, 3 zones in which it would be deployed. If zonal, just 1 location"
  default     = ["us-central1-a"]
}
