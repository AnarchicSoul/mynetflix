variable "password" {
    type        = string
}  
variable "namespace" {
    type = string
}  
variable "jenkins_ingress" {
    type        = string
}  
variable "jenkins" {
    type        = bool
}  
variable "keycloak_ingress" {
    type        = string
}  
variable "keycloak" {
    type        = bool
} 
variable "prometheus" {
    type        = bool
} 
variable "sonarqube" {
    type        = bool
} 
variable "sonarqube_password" {
    type        = string
}  
variable "sonarqube_ingress" {
    type        = string
}  
variable "myapp" {
    type        = bool
} 
variable "myapp_ingress" {
    type        = string
}  