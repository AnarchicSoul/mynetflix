#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "sftpgo" {
  name       = "jenkins"
  namespace  = module.k8s_cluster.namespace
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.2.0"

  values = [
    "${file("values.yaml")}"
  ]

#  set {
#      name  = "api.ingress.hosts[0].host"
#      value = "sbil-api-k8s${module.k8s_cluster.platform}.${module.k8s_cluster.ticketing_dns_domain}"
#    }
  
} 
