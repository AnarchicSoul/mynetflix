#######################################################################################
# HELM INSTALL
#######################################################################################

resource "helm_release" "jenkins" {
  name       = "jenkins"
  namespace  = var.namespace
  chart      = "./jenkins/jenkins-5.2.0.tgz"
  version    = "5.2.0"

  values = [
    "${file("./jenkins/values.yaml")}"
  ]

  set {
      name  = "controller.admin.password"
      value = var.password
    }
  set {
      name  = "controller.ingress.hostName"
      value = var.jenkins_ingress
    }
  
} 
