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
    var.keycloak ? local.keycloak_config : local.nokeycloak_config
  ]

  set {
      name  = "grafana.adminPassword"
      value = var.password
    }
  set {
      name  = "prometheus.ingress.hosts[0]"
      value = var.prometheus_ingress
    }
  set {
      name  = "grafana.ingress.hosts[0]"
      value = var.grafana_ingress
    }
  set {
      name  = "alertmanager.ingress.hosts[0]"
      value = var.alert_ingress
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
#    prometheus:
#      ingress:
#        tls: 
#          - secretName: wildcard-cert
#            hosts:
#            - ${var.prometheus_ingress}
  keycloak_config = <<-EOT
    alertmanager:
      ingress:
        tls: 
          - secretName: wildcard-cert
            hosts:
            - ${var.alert_ingress}
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
