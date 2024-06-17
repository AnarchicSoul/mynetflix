#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "prom_stack" {
  name       = "promstack"
  namespace  = var.namespace
  chart      = "./prometheus/kube-prometheus-stack-60.1.0.tgz"
  version    = "60.1.0"

  values = [
    "${file("./prometheus/values.yaml")}"
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