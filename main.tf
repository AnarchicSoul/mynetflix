#######################################################################################
# Terraform Providers
#######################################################################################

# Define required providers
terraform {
required_version = ">= 0.14.0"
  cloud {
    organization = "johanduval"
    workspaces {
      name = "master"
    }
  }
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
      configuration_aliases = [ helm.alternate ]
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "./k8s-cluster/kubeconfig"
  }
}

provider "kubernetes" {
  config_path    = "./k8s-cluster/kubeconfig"
}
