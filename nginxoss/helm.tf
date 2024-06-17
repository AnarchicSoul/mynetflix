#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "nginx" {
  name       = "nginx"
  namespace  = "kube-system"
  chart      = "./nginxoss/ingress-nginx-4.10.1.tgz"
  version    = "4.10.1"
} 
