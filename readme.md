# MyNetflix

## Description
MyNetflix is an educational infrastructure project designed to demonstrate how to deploy and manage cloud services and applications using Kubernetes and Terraform. The project is structured in three levels:

1. **Small lab with Docker Desktop**
2. **Simulated production environment with RKE2 deployment**
3. **Production environment on Azure Cloud**

## Project Structure
- `cert-manager/`: SSL certificate management configuration.
- `devpack/`: Development packs.
- `docs/`: Project documentation.
- `gravitee/`: API Management with Gravitee.
- `homer/`: Homer dashboard.
- `k8s-cluster/`: Kubernetes cluster configuration.
- `keycloak/`: Identity management with Keycloak.
- `netflix/`: Netflix-specific services.
- `prometheus/`: Monitoring and alerting with Prometheus.

## Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Terraform](https://www.terraform.io/)
- [Kubernetes](https://kubernetes.io/)
- [Helm](https://helm.sh/)
- [RKE2](https://docs.rke2.io/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Installation

### Level 1: Small Lab with Docker Desktop
1. Clone the repository:
    ```sh
    git clone https://github.com/AnarchicSoul/mynetflix.git
    cd mynetflix
    ```

2. Launch Docker Desktop.

3. Deploy the infrastructure:
    ```sh
    terraform init
    terraform apply
    ```

4. Install Helm charts:
    ```sh
    ./install.sh
    ```

### Level 2: Simulated Production Environment with RKE2 Deployment
1. Follow the instructions in `docs/rke2-setup.md` to set up RKE2.

2. Deploy the infrastructure with Terraform and Helm as in Level 1.

### Level 3: Production Environment on Azure Cloud
1. Follow the instructions in `docs/azure-setup.md` to set up Azure Cloud.

2. Deploy the infrastructure with Terraform and Helm as in Level 1.

## Uninstallation
To uninstall the infrastructure:
```sh
./uninstall.sh
terraform destroy
