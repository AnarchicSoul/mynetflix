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
            ${var.prometheus ? local.client_prometheus : ""}
            ${var.prometheus ? local.client_grafana : ""}
            ${var.prometheus ? local.client_alertmanager : ""}
            ${var.prometheus ? local.client_mailhog : ""}
            ${var.prometheus ? local.client_kubeshark : ""}
            ${var.prometheus ? local.client_homer : ""}
            ${var.myapp ? local.client_myapp : ""}
            ${var.jenkins ? local.client_jenkins : ""}
            ${var.sonarqube ? local.client_sonarqube : ""}
            ${local.client_fake}
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
metrics:
  serviceMonitor:
    enabled: ${var.prometheus ? "true" : "false"}
  prometheusRule:
    enabled: ${var.prometheus ? "true" : "false"}
  EOT
}

