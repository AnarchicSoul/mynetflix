#######################################################################################
## Base Config
#######################################################################################
# Careful if you modify this part, be sure to know your cluster. 
# Base component can be disabled from install, but be sure they exists ! 


## Common config
variable "docker_desktop" {
  # docker_desktop workarround 
  type  = bool
  default = true
}
locals {
    mydomain    = "${yamldecode(file("config.yaml")).baseconfig.common.mydomain}"
}


## Kubernetes config 
variable "certmgr" {
    description = "enable = true & disable = false"
    type        = bool
    default     = true
} 
variable "nginxoss" {
    description = "enable = true & disable = false"
    type        = bool
    default     = true
} 
locals {
    namespace    = "${yamldecode(file("config.yaml")).baseconfig.kubernetes.namespace}"
}


## Kube prometheus stack config
variable "grafana_password" {
    description = "Type grafana password"
    type        = string
    sensitive   = true
    # remove default if you want secure password 
    default     = "admin"
}  
locals {
    grafana_host = "${yamldecode(file("config.yaml")).baseconfig.prometheus.grafana_host}"
    alert_host    = "${yamldecode(file("config.yaml")).baseconfig.prometheus.alertmanager_host}"
    prometheus_host    = "${yamldecode(file("config.yaml")).baseconfig.prometheus.prometheus_host}"
    grafana_ingress = "${local.grafana_host}.${local.mydomain}"
    alert_ingress = "${local.alert_host}.${local.mydomain}"
    prometheus_ingress = "${local.prometheus_host}.${local.mydomain}"
}


## Keycloak Config
variable "keycloak" {
    description = "enable = true & disable = false"
    type        = bool
    default     = true
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
locals {
    keycloak_host = "${yamldecode(file("config.yaml")).baseconfig.keycloak.keycloak_host}"
    keycloak_ingress = "${local.keycloak_host}${var.docker_desktop ? ".${local.namespace}.svc.cluster.local" : ".${local.mydomain}"}"
}


#######################################################################################
## Application Config
#######################################################################################
# Normally everything should work. :)


## Jenkins Config
variable "jenkins" {
    description = "enable = true & disable = false"
    type        = bool
    default     = true
}  
variable "jenkins_password" {
    description = "Type jenkins password"
    type        = string
    sensitive   = true
    # remove default if you want secure password 
    default     = "admin"
}  
locals {
    jenkins_host    = "${yamldecode(file("config.yaml")).app.jenkins.jenkins_host}"
    jenkins_ingress = "${local.jenkins_host}.${local.mydomain}"
}