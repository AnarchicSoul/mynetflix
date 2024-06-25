#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "prom_stack" {
  name       = "promstack"
  namespace  = var.namespace
  chart      = "./prometheus/kube-prometheus-stack-60.1.0.tgz"
  version    = "60.1.0"

  values = [
    "${file("./prometheus/values.yaml")}",
    var.keycloak ? local.keycloak_config : local.nokeycloak_config,
    var.keycloak ? "" : local.prometheus_ingress,
    var.keycloak ? "" : local.alert_ingress
  ]

  set {
      name  = "grafana.adminPassword"
      value = var.password
    }
  set {
      name  = "grafana.ingress.hosts[0]"
      value = var.grafana_ingress
    }

} 

resource "null_resource" "execute_sh" {
  depends_on = [helm_release.prom_stack]
  count = var.docker_desktop ? 1 : 0 

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./k8s-cluster/kubeconfig patch ds promstack-prometheus-node-exporter --type \"json\" -p '[{\"op\": \"remove\", \"path\" : \"/spec/template/spec/containers/0/volumeMounts/2/mountPropagation\"}]' -n toto"
  }
}


locals {
  keycloak_config = <<-EOT
    grafana:
      ingress:
        tls: 
          - secretName: wildcard-cert
            hosts:
            - ${var.grafana_ingress}
      grafana.ini:
        auth.generic_oauth:
          enabled: true
          name: Keycloak-OAuth
          allow_sign_up: true
          client_id: grafana
          scopes: openid email profile roles
          auth_url: http://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/auth
          token_url: http://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/token
          api_url: http://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo
          redirect_uri: http://${var.grafana_ingress}/login/generic_oauth
          role_attribute_path: contains(realm_access.roles[*], 'admin') && 'Admin' || contains(realm_access.roles[*], 'editor') && 'Editor' || 'Viewer'
        server:
          root_url: http://${var.grafana_ingress}/
  EOT
  nokeycloak_config = <<-EOT
    nameOverride: ""
  EOT
}

resource "helm_release" "oauth_prometheus" {
  count = var.keycloak ? 1 : 0
  depends_on = [helm_release.prom_stack]
  name       = "prometheus"
  namespace  = var.namespace
  chart      = "./prometheus/oauth2-proxy-7.7.4.tgz"
  version    = "7.7.4"
  values = [
    "${file("./prometheus/oauth.yaml")}",
    local.prometheus_config
  ]
} 
resource "helm_release" "oauth_alert" {
  count = var.keycloak ? 1 : 0
  depends_on = [helm_release.prom_stack]
  name       = "alertmanager"
  namespace  = var.namespace
  chart      = "./prometheus/oauth2-proxy-7.7.4.tgz"
  version    = "7.7.4"
  values = [
    "${file("./prometheus/oauth.yaml")}",
    local.alert_config
  ]
} 

locals {
  prometheus_config = <<-EOT
    ingress:
      hosts:
        - ${var.prometheus_ingress}
      tls: 
        - secretName: wildcard-cert
          hosts:
          - ${var.prometheus_ingress}
    extraArgs:
      client-id: prometheus
      login-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/auth" 
      redeem-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/token"
      profile-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo" 
      validate-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo"
      upstream: "http://promstack-kube-prometheus-prometheus.${var.namespace}.svc.cluster.local:9090"
  EOT
  prometheus_ingress = <<-EOT
    prometheus:
      ingress:
        enabled: true
        hosts:
          - ${var.prometheus_ingress}
        tls: 
          - secretName: wildcard-cert
            hosts:
            - ${var.prometheus_ingress}
  EOT
  alert_config = <<-EOT
    ingress:
      hosts:
        - ${var.alert_ingress}
      tls: 
        - secretName: wildcard-cert
          hosts:
          - ${var.alert_ingress}
    extraArgs:
      client-id: alertmanager
      login-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/auth" 
      redeem-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/token"
      profile-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo" 
      validate-url: "https://${var.keycloak_ingress}/realms/realm1/protocol/openid-connect/userinfo"
      upstream: "http://promstack-kube-prometheus-alertmanager.${var.namespace}.svc.cluster.local:9093"
  EOT
  alert_ingress = <<-EOT
    alertmanager:
      ingress:
        enabled: true
      hosts:
        - ${var.alert_ingress}
      tls: 
        - secretName: wildcard-cert
          hosts:
          - ${var.alert_ingress}
  EOT
}