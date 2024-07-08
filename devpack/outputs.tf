output "jenkinspass" {
    value = nonsensitive(var.password)
}
output "sonarqubepass" {
    value = nonsensitive(var.sonarqube_password)
}
