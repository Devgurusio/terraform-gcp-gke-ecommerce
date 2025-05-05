terraform {
  required_version = ">= 1.10.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.33.0"
    }
    random = {
      version = "~> 3.6.3"
    }
  }
}
