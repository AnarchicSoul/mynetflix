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
}

module "jenkins" {
    source = "jenkins"
}

