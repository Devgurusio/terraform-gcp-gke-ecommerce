terraform {
  required_version = "~> 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.47"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.47"
    }
    random = {
      version = "~> 3.0.0"
    }
  }
}
