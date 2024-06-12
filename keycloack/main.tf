#######################################################################################
# Terraform Providers
#######################################################################################

# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "./k8s-cluster/kubeconfig"
  }
}

module "k8s_cluster" {
    source = "../k8s-cluster"
}