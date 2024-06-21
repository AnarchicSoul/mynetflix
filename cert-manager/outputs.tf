output "myca" {
  sensitive = true
  value = lookup(data.kubernetes_secret.myca.data, "ca.crt")
}