#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "oauth" {
  name       = "oauth"
  namespace  = var.namespace
  chart      = "./oauth2/oauth2-proxy-7.7.4.tgz"
  version    = "7.7.4"
  values = [
    "${file("./oauth2/values.yaml")}"
  ]
} 