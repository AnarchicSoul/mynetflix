#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "certmgr" {
  name       = "certmgr"
  namespace  = "kube-system"
  chart      = "./cert-manager/cert-manager-v1.15.0.tgz"
  version    = "1.15.0"

  set {
      name  = "crds.enabled"
      value = true
    }

} 
