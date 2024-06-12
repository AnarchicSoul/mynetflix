output "keycloakpass" {
    value = module.keycloak.keycloakpass
}
output "jenkinspass" {
    value = module.jenkins.jenkinspass
}
output "namespace" {
  value = module.k8s_cluster.namespace
}