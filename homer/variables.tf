variable "homer" {
    type        = bool
} 
variable "homer_ingress" {
    type        = string
}  
variable "keycloak" {
    type        = bool
} 
variable "keycloak_ingress" {
    type        = string
}  
variable "prometheus_ingress" {
    type        = string
}  
variable "grafana_ingress" {
    type        = string
}  
variable "alert_ingress" {
    type        = string
}  
variable "mailhog_ingress" {
    type        = string
}  
variable "kubeshark_ingress" {
    type        = string
}  
variable "devpack" {
    type        = bool
} 
variable "jenkins" {
    type        = bool
} 
variable "jenkins_ingress" {
    type        = string
}  
variable "sonarqube" {
    type        = bool
} 
variable "sonarqube_ingress" {
    type        = string
}  
variable "namespace" {
    type = string
}  