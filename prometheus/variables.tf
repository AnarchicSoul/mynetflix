variable "prometheus_ingress" {
    type        = string
}  
variable "alert_ingress" {
    type        = string
}  
variable "grafana_ingress" {
    type        = string
}  
variable "mailhog_ingress" {
    type        = string
}  
variable "keycloak_ingress" {
    type        = string
}  
variable "password" {
    type        = string
}  
variable "namespace" {
    type = string
}  
variable "docker_desktop" {
    type = bool
}  
variable "keycloak" {
    type        = bool
} 