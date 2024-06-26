#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "keycloak" {
  name       = "keycloak"
  namespace  = var.namespace
  chart      = "./keycloak/keycloak-21.4.1.tgz"

  values = [
    "${file("./keycloak/values.yaml")}",
    local.keycloak_config
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

locals {
  keycloak_config = <<-EOT
ingress:
  extraTls:
    - secretName: wildcard-cert
      hosts:
        - ${var.keycloak_ingress}
keycloakConfigCli:
  configuration: 
    realm1.json: |
        {
          "realm": "realm1",
          "enabled": true,
          "clients": [
            ${local.client_prometheus}
            ${local.client_grafana}
            ${local.client_mailhog}
            ${var.homer ? local.client_homer : ""}
            ${var.jenkins ? local.client_jenkins : ""}
            ${local.client_alertmanager}
          ],
          "users": [
            {
              "username": "admin",
              "enabled": true,
              "emailVerified": true,
              "firstName": "Rootus",
              "lastName": "Adminus",
              "email": "local-admin@mail.com",
              "credentials": [
                {
                  "type": "password",
                  "value": "${var.superadmin}"
                }
              ]
            }
          ]
        }
  EOT
}

