variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
  default     = "project-gaia-101"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "zones" {
  type        = list(string)
  description = "The zone to host the cluster in (required if is a zonal cluster)"
  default     = ["us-central1-a", "us-central1-b", "us-central1-f"]
}
