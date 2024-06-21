## docker_desktop workarround 
variable "docker_desktop" {
  type  = bool
  default = true
}

## Kubernetes config 
variable "namespace" {
  default = "toto"
}  

## Kube prometheus stack config
variable "grafana_password" {
    description = "Type grafana password"
    type        = string
    sensitive   = true
    # remove default if you want secure password 
    default     = "admin"
}  
variable "grafana_ingress" {
    description = "Type grafana ingress"
    type        = string
    default     = "grafana.localhost"
}  
variable "alert_ingress" {
    description = "Type grafana ingress"
    type        = string
    default     = "alertmanager.localhost"
}  
variable "prometheus_ingress" {
    description = "Type grafana ingress"
    type        = string
    default     = "prometheus.localhost"
}  

## Keycloak Config
variable "keycloak" {
    description = "enable = true & disable = false"
    type        = bool
    default     = false
} 
variable "keycloak_password" {
    description = "Type keycloak password"
    type        = string
    sensitive   = true
    # remove default if you want secure password 
    default     = "admin"
}  
variable "superadmin" {
    description = "Type keycloak superadmin password who will access all applications"
    type        = string
    sensitive   = true
    # remove default if you want secure password 
    default     = "superadmin"
}  
variable "keycloak_ingress" {
    description = "Type keycloak ingress"
    type        = string
    default     = "keycloak"
}  

## Jenkins Config
variable "jenkins" {
    description = "enable = true & disable = false"
    type        = bool
    default     = false
}  
variable "jenkins_password" {
    description = "Type jenkins password"
    type        = string
    sensitive   = true
    # remove default if you want secure password 
    default     = "admin"
}  
variable "jenkins_ingress" {
    description = "Type jenkins ingress"
    type        = string
    default     = "jenkins.localhost"
}  