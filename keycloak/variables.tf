variable "password" {
    type        = string
}  
variable "superadmin" {
    type        = string
}  
variable "namespace" {
    type = string
}  
variable "keycloak_ingress" {
    type        = string
}  
variable "grafana_ingress" {
    type        = string
}  
variable "prometheus_ingress" {
    type        = string
}  
variable "alert_ingress" {
    type        = string
}  
variable "mailhog_ingress" {
    type        = string
}  
variable "jenkins" {
    type        = bool
}  
variable "jenkins_ingress" {
    type        = string
}  
variable "homer" {
    type        = bool
}  
variable "homer_ingress" {
    type        = string
}  