#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "jenkins" {
  name       = "jenkins"
  namespace  = module.k8s_cluster.namespace
#  repository = "https://charts.jenkins.io"
  chart      = "./jenkins/jenkins-5.2.0.tgz"
  version    = "5.2.0"

  values = [
    "${file("./jenkins/values.yaml")}"
  ]

  set {
      name  = "controller.admin.password"
      value = var.password
    }
  
} 
