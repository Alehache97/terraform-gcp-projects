terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.45.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "google" {
  project = "proven-mystery-473711-n3"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}
