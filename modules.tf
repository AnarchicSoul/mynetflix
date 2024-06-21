module "k8s_cluster" {
    source = "./k8s-cluster"
    namespace  = var.namespace
}

module "nginxoss" {
    source = "./nginxoss"
    depends_on = [module.k8s_cluster]
}

module "certmgr" {
    source = "./cert-manager"
    namespace  = module.k8s_cluster.namespace
    depends_on = [module.k8s_cluster]
}

module "prometheus" {
    source = "./prometheus"
    namespace  = module.k8s_cluster.namespace
    password  = var.grafana_password
    docker_desktop  = var.docker_desktop
    prometheus_ingress  = var.prometheus_ingress
    alert_ingress  = var.alert_ingress
    grafana_ingress  = var.grafana_ingress
    keycloak_ingress  = var.keycloak_ingress
    keycloak = var.keycloak
    depends_on = [module.nginxoss]
}

module "keycloak" {
    count  = var.keycloak ? 1 : 0
    source = "./keycloak"
    namespace  = module.k8s_cluster.namespace
    password  = var.keycloak_password
    superadmin  = var.superadmin
    keycloak_ingress  = var.keycloak_ingress
    grafana_ingress  = var.grafana_ingress
    jenkins_ingress  = var.jenkins_ingress
    depends_on = [module.prometheus]
}

module "jenkins" {
    count  = var.jenkins ? 1 : 0
    source = "./jenkins"
    namespace  = module.k8s_cluster.namespace
    password  = var.jenkins_password
    jenkins_ingress  = var.jenkins_ingress
    keycloak_ingress  = var.keycloak_ingress
    keycloak = var.keycloak
    depends_on = [module.keycloak]
}

module "oauth" {
    source = "./oauth2"
    namespace  = module.k8s_cluster.namespace
    depends_on = [module.keycloak]
}