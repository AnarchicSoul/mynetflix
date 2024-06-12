variable "password" {
    description = "Type keycloak password"
    type        = string
    sensitive   = true
    default     = "admin"
}  