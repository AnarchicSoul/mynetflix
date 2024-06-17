#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "keycloak" {
  name       = "keycloak"
  namespace  = var.namespace
  chart      = "./keycloak/keycloak-21.4.1.tgz"

  values = [
    "${file("./keycloak/values.yaml")}"
  ]

  set {
      name  = "auth.adminPassword"
      value = var.password
    }
  set {
      name  = "ingress.hostname"
      value = var.keycloak_ingress
    }
  
} 
