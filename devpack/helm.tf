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


## TEMP APP POST INSTALL
resource "kubernetes_secret" "myapp" {
  metadata {
    name = "ntt-data"
    namespace  = var.namespace
  }

  data = {
    "user" = "toto"
    "password" = "super_toto"
  }

  type = "opaque"
}

resource "helm_release" "myapp" {
  count = var.myapp ? 1 : 0
  depends_on = [kubernetes_secret.myapp]
  name       = "myapp-app"
  namespace  = var.namespace
  chart      = "./devpack/testpy/myapp-0.13.0.tgz"
  values = [
    var.keycloak ? local.myapp_noconfig : local.myapp_config
  ]
} 

resource "helm_release" "oauth_myapp" {
  count = var.keycloak && var.myapp ? 1 : 0
  depends_on = [helm_release.myapp]
  name       = "myapp"
  namespace  = var.namespace
  chart      = "./keycloak/oauth2/oauth2-proxy-7.7.4.tgz"
  version    = "7.7.4"
  values = [
    "${file("./keycloak/oauth2/values.yaml")}",
    local.myapp_oauth
  ]
} 

locals {
  myapp_config = <<-EOT
    ingress:
      enabled: true
      hosts:
        - host: ${var.myapp_ingress}
          paths:
            - path: /
              backend:
                serviceName: myapp-app-service
                servicePort: 80
      tls:
        - secretName: wildcard-cert
          hosts:
            - ${var.myapp_ingress}
  EOT

  myapp_noconfig = <<-EOT
    ingress:
      enabled: false
  EOT
  
  myapp_oauth = <<-EOT
    ingress:
      hosts:
        - ${var.myapp_ingress}
      tls: 
        - secretName: wildcard-cert
          hosts:
          - ${var.myapp_ingress}
    extraArgs:
      client-id: myapp
      login-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/auth" 
      redeem-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/token"
      profile-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo" 
      validate-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo"
      upstream: "http://myapp-app-service.${var.namespace}.svc.cluster.local:80"
  EOT
}