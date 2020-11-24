variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

variable "zone" {
  type        = string
  description = "The zone to host the cluster in. Default: us-central1-a"
  default     = "us-central1-a"
}
