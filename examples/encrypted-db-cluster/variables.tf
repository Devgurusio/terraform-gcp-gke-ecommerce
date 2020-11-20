variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in. Default: us-central1"
  default     = "us-central1"
}
