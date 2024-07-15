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
    var.keycloak ? local.keycloak_config : "",
    var.prometheus ? local.prometheus_config : ""
  ]

  set {
      name  = "controller.admin.password"
      value = var.password
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
  prometheus_config = <<-EOT
    controller:
      prometheus:
        enabled: true
  EOT
}

resource "helm_release" "sonarqube" {
  count = var.sonarqube ? 1 : 0
  name       = "sonarqube-app"
  namespace  = var.namespace
  chart      = "./devpack/sonarqube-10.5.1+2816.tgz"
  version    = "10.5.1+2816"

  values = [
    var.keycloak ? "" : local.sonarqube_config,
    var.prometheus ? local.sonarqube_config : ""
  ]

  set {
      name  = "account.adminPassword"
      value = var.sonarqube_password
    }
  set {
      name  = "account.currentAdminPassword"
      value = var.sonarqube_password
    }
} 

resource "helm_release" "oauth_sonarqube" {
  count = var.keycloak && var.sonarqube ? 1 : 0
  depends_on = [helm_release.sonarqube]
  name       = "sonarqube"
  namespace  = var.namespace
  chart      = "./keycloak/oauth2/oauth2-proxy-7.7.4.tgz"
  version    = "7.7.4"
  values = [
    "${file("./keycloak/oauth2/values.yaml")}",
    local.sonarqube_oauth
  ]
} 

locals {
  sonarqube_config = <<-EOT
    ingress:
      ingressClassName: nginx
      enabled: true
      hosts:
        - name: ${var.sonarqube_ingress}
      tls:
        - secretName: wildcard-cert
          hosts:
            - ${var.sonarqube_ingress}
  EOT
  
  sonarqube_oauth = <<-EOT
    ingress:
      hosts:
        - ${var.sonarqube_ingress}
      tls: 
        - secretName: wildcard-cert
          hosts:
          - ${var.sonarqube_ingress}
    extraArgs:
      client-id: sonarqube
      login-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/auth" 
      redeem-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/token"
      profile-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo" 
      validate-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo"
      upstream: "http://sonarqube-app-sonarqube.${var.namespace}.svc.cluster.local:9090"
  EOT

  sonarqube_monitoring = <<-EOT
    prometheusMonitoring:
      podMonitor:
        enabled: true
  EOT
}
