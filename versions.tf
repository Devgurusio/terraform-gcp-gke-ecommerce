terraform {
  required_version = ">= 1.10.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.17.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.17.0"
    }
    random = {
      version = "~> 3.6.3"
    }
  }
}
