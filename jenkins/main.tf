#######################################################################################
# Terraform Providers
#######################################################################################

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
    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "/home/administrator/.kube/config.03.2024"
    config_context = "docker-desktop"
  }
}

module "k8s_cluster" {
    source = "../modules/k8s-cluster"
}

