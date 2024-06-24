module "k8s_cluster" {
    source = "./k8s-cluster"
    namespace  = local.namespace
    certmgr = var.certmgr
    nginxoss = var.nginxoss
}

module "certmgr" {
    source = "./cert-manager"
    namespace = module.k8s_cluster.namespace
    mydomain = local.mydomain
    depends_on = [module.k8s_cluster]
}

module "prometheus" {
    source = "./prometheus"
    namespace  = module.k8s_cluster.namespace
    password  = var.grafana_password
    docker_desktop  = var.docker_desktop
    prometheus_ingress  = local.prometheus_ingress
    alert_ingress  = local.alert_ingress
    grafana_ingress  = local.grafana_ingress
    keycloak_ingress  = local.keycloak_ingress
    keycloak = var.keycloak
    depends_on = [module.certmgr]
}

module "keycloak" {
    count  = var.keycloak ? 1 : 0
    source = "./keycloak"
    namespace  = module.k8s_cluster.namespace
    password  = var.keycloak_password
    superadmin  = var.superadmin
    keycloak_ingress  = local.keycloak_ingress
    grafana_ingress  = local.grafana_ingress
    jenkins_ingress  = local.jenkins_ingress
    depends_on = [module.prometheus]
}

module "jenkins" {
    count  = var.jenkins ? 1 : 0
    source = "./jenkins"
    namespace  = module.k8s_cluster.namespace
    password  = var.jenkins_password
    jenkins_ingress  = local.jenkins_ingress
    keycloak_ingress  = local.keycloak_ingress
    keycloak = var.keycloak
    depends_on = [module.keycloak]
}

module "oauth" {
    source = "./oauth2"
    namespace  = module.k8s_cluster.namespace
    depends_on = [module.keycloak]
}