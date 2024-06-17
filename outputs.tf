output "keycloakpass" {
  value = var.keycloak ? module.keycloak[0].keycloakpass : null
}
output "jenkinspass" {
  value = var.jenkins ? module.jenkins[0].jenkinspass : null
}
output "grafanapass" {
  value = nonsensitive(var.grafana_password)
}
output "namespace" {
  value = module.k8s_cluster.namespace
}