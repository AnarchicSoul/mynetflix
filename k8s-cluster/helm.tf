#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "certmgr" {
  name       = "certmgr"
  namespace  = "kube-system"
  chart      = "./k8s-cluster/cert-manager-v1.15.0.tgz"
  version    = "1.15.0"

  set {
      name  = "crds.enabled"
      value = true
    }

  count  = var.certmgr ? 1 : 0
} 
#resource "null_resource" "delete_certmgr_crds" {
#  provisioner "local-exec" {
#    when    = destroy
#    command = <<EOT
#kubectl --kubeconfig ./k8s-cluster/kubeconfig delete crd \
#  certificates.cert-manager.io \
#  challenges.acme.cert-manager.io \
#  clusterissuers.cert-manager.io \
#  issuers.cert-manager.io \
#  orders.acme.cert-manager.io
#EOT
#  }
#
#  depends_on = [helm_release.certmgr]
#}


resource "helm_release" "nginx" {
  name       = "nginx"
  namespace  = "kube-system"
  chart      = "./k8s-cluster/ingress-nginx-4.10.1.tgz"
  version    = "4.10.1"
  count  = var.nginxoss ? 1 : 0

  set {
      name  = "controller.config.allow-snippet-annotations"
      value = true
    }
  set {
      name  = "controller.config.use-forwarded-headers"
      value = true
    }

} 


resource "helm_release" "redis" {
  count  = var.keycloak ? 1 : 0
  name       = "redis"
  namespace  = var.namespace
  chart      = "./keycloak/redis/redis-19.5.5.tgz"
  version    = "19.5.5"
  set {
      name  = "metrics.enabled"
      value = "true"
    }
  set {
      name  = "architecture"
      value = "standalone"
    }
} 
