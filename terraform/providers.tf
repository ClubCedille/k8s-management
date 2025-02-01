terraform {
  cloud {
        organization = "cedille"
        workspaces {
            name = "k8s-management"
        }
    }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">=6.0.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.35.0"
    }
  }
}

provider "kubernetes" {
    host = var.kubernetes_endpoint
    token = var.kubernetes_token
}

provider "google" {
  project = var.gcloud_project
  region  = var.gcloud_region
}