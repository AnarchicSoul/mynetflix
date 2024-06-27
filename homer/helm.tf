#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "homer" {
  name       = "homer-app"
  namespace  = var.namespace
  chart      = "./homer/homer-8.1.12.tgz"
  version    = "60.1.0"

  values = [
    local.homer_config,
    var.keycloak ? "" : local.homer_ingress
  ]

} 


locals {
  homer_config = <<-EOT
    configmap:
      config:
        enabled: true
        data:
          config.yml: |
            title: "My Home Routing"
            subtitle: "Duval Johan"
            header: true
            footer: false # set false if you want to hide it.
            services:
              - name: "Monitoring"
                items:
                  - name: "Prometheus"
                    url: "https://${var.prometheus_ingress}"
                  - name: "Grafana"
                    url: "https://${var.grafana_ingress}"
                  - name: "AlertManager"
                    url: "https://${var.alert_ingress}"
                  - name: "Mailhog"
                    url: "https://${var.mailhog_ingress}"
                  - name: "Kubeshark"
                    url: "https://${var.kubeshark_ingress}"
              ${var.keycloak ? "- name: \"Security\"\n            items:\n              - name: \"Keycloak\"\n                url: \"https://${var.keycloak_ingress}\"" : ""}
              ${var.devpack ? "- name: \"Devpack\"\n            items:" : ""}
                  ${var.jenkins ? "- name: \"jenkins\"\n                url: \"https://${var.jenkins_ingress}\"" : ""}
              - name: "My Apps"
                items:
                  - name: "Homer"
                    url: "https://${var.homer_ingress}"
  EOT
}

resource "helm_release" "oauth_homer" {
  count = var.keycloak ? 1 : 0
  depends_on = [helm_release.homer]
  name       = "homer"
  namespace  = var.namespace
  chart      = "./keycloak/oauth2/oauth2-proxy-7.7.4.tgz"
  version    = "7.7.4"
  values = [
    "${file("./keycloak/oauth2/values.yaml")}",
    local.homer_oauth
  ]
} 

locals {
  homer_oauth = <<-EOT
    ingress:
      hosts:
        - ${var.homer_ingress}
      tls: 
        - secretName: wildcard-cert
          hosts:
          - ${var.homer_ingress}
    extraArgs:
      client-id: homer
      login-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/auth" 
      redeem-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/token"
      profile-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo" 
      validate-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo"
      upstream: "http://homer-app.${var.namespace}.svc.cluster.local:8080"
  EOT
  homer_ingress = <<-EOT
    ingress:
      main:
        enabled: true
        ingressClassName: nginx
        hosts: 
          - host: ${var.homer_ingress}
            paths:
              - path: /
                pathType: Prefix
        tls: 
          - secretName: wildcard-cert
            hosts:
            - ${var.homer_ingress}
  EOT
}
