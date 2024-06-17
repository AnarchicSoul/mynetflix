#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "jenkins" {
  name       = "jenkins"
  namespace  = var.namespace
  chart      = "./jenkins/jenkins-5.2.0.tgz"
  version    = "5.2.0"

  values = [
    "${file("./jenkins/values.yaml")}",
    var.keycloak ? local.keycloak_config : local.nokeycloak_config
  ]

  set {
      name  = "controller.admin.password"
      value = var.password
    }
  set {
      name  = "controller.ingress.hostName"
      value = var.jenkins_ingress
    }
} 

locals {
  keycloak_config = <<-EOT
    controller:
      JCasC:
        configScripts:
          keycloak: |
            jenkins:
              securityRealm:
                keycloak:
                  keycloakJson: |-
                    {
                      "realm": "realm1",
                      "auth-server-url": "http://${var.keycloak_ingress}/",
                      "ssl-required": "external",
                      "resource": "jenkins",
                      "public-client": true,
                      "confidential-port": 0
                    }
  EOT
  nokeycloak_config = <<-EOT
    clusterZone: "cluster.local"
  EOT
}

