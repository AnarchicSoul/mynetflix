#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "gravitee" {
  name       = "gravitee"
  namespace  = "toto"
  chart      = "./gravitee/apim-4.4.1.tgz"
  version    = "4.4.1"
  values = [
    "${file("./gravitee/values.yaml")}",
  ]
} 


