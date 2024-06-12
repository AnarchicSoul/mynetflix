module "k8s_cluster" {
    source = "./k8s-cluster"
}

module "jenkins" {
    source = "./jenkins"
}

module "keycloak" {
    source = "./keycloak"
}