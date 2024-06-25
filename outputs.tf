output "keycloakpass" {
  value = var.keycloak ? module.keycloak[0].keycloakpass : null
  sensitive = true
}
output "superadminpass" {
  value = var.keycloak ? module.keycloak[0].superadmin : null
  sensitive = true
}
output "jenkinspass" {
  value = var.jenkins ? module.devpack[0].jenkinspass : null
  sensitive = true
}
output "grafanapass" {
  value = nonsensitive(var.grafana_password)
  sensitive = true
}
output "namespace" {
  value = module.k8s_cluster.namespace
}
output "myca" {
  value = nonsensitive(module.certmgr.myca)
}