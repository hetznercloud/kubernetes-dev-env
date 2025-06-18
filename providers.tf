terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.1, < 3.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5, < 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "< 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.31.0, < 3.0.0"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.48.0, < 2.0.0"
    }
  }
}
