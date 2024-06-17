output "keycloakpass" {
    value = nonsensitive(var.password)
}
output "superadmin" {
    value = nonsensitive(var.superadmin)
}
