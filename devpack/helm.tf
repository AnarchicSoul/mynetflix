#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "jenkins" {
  count = var.jenkins ? 1 : 0
  name       = "jenkins"
  namespace  = var.namespace
  chart      = "./devpack/jenkins-5.2.0.tgz"
  version    = "5.2.0"

  values = [
    "${file("./devpack/values.yaml")}",
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
      ingress:
        tls: 
          - secretName: wildcard-cert
            hosts:
            - ${var.jenkins_ingress}
      JCasC:
        configScripts:
          keycloak: |
            jenkins:
              securityRealm:
                keycloak:
                  keycloakJson: |-
                    {
                      "realm": "realm1",
                      "auth-server-url": "https://${var.keycloak_ingress}/",
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

resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  namespace  = var.namespace
  chart      = "./devpack/sonarqube-10.5.1+2816.tgz"
  version    = "10.5.1+2816"

} 
