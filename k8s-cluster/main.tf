# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
}


provider "kubernetes" {
  config_path    = "./k8s-cluster/kubeconfig"
}

