# Define required providers
terraform {
required_version = ">= 0.14.0"
  cloud {
    organization = "johanduval"
    workspaces {
      name = "mynetflix"
    }
  }
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
}

provider "kubernetes" {
  config_path    = "/home/administrator/.kube/config.03.2024"
  config_context = "docker-desktop"
}
