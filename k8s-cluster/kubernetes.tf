resource "kubernetes_namespace_v1" "example" {
  metadata {
    name = var.namespace
  }
}