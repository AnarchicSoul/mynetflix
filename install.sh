#!/bin/bash

# Apply the helm_release first
terraform apply -target=module.k8s_cluster -auto-approve

# Apply the remaining resources
terraform apply -auto-approve
