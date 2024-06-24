resource "kubernetes_secret" "jks" {
  metadata {
    name = "jks-password-secret"
    namespace = "${var.namespace}"
  }
  
  data = {
    password-key = "tatayoyo"
    tls-keystore-password = "tatayoyo"
    tls-truststore-password = "tatayoyo"
  }
}

resource "kubernetes_manifest" "cluster_self_issuer" {
  manifest = yamldecode(<<-EOF
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: localsvc-issuer
    spec:
      selfSigned: {}
    EOF
  )
  depends_on = [kubernetes_secret.jks]
}

resource "kubernetes_manifest" "certificate_ca" {
  manifest = yamldecode(<<-EOF
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: localsvc-ca
      namespace: ${var.namespace}
    spec:
      isCA: true
      commonName: localsvc-ca
      secretName: root-ca-svc-secret
      privateKey:
        algorithm: ECDSA
        size: 256
      issuerRef:
        kind: ClusterIssuer
        name: localsvc-issuer
      keystores:
        jks:
          create: true
          passwordSecretRef:
            key: password-key
            name: jks-password-secret
    EOF
  )
  depends_on = [
    kubernetes_manifest.cluster_self_issuer]
}

resource "kubernetes_manifest" "final_issuer" {
  manifest = yamldecode(<<-EOF
    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: test-issuer
      namespace: ${var.namespace}
    spec:
      ca:
        secretName: root-ca-svc-secret
    EOF
  )
  depends_on = [kubernetes_manifest.certificate_ca]
}

resource "kubernetes_manifest" "certificate_wildcard" {
  manifest = yamldecode(<<-EOF
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: wildcard
      namespace: ${var.namespace}
    spec:
      isCA: false
      dnsNames:
        - "*.${var.namespace}.svc.cluster.local"
        - "*.${var.mydomain}"
      subject:
        organizations:
          - quickstart
      privateKey:
        algorithm: RSA
        encoding: PKCS1
        size: 2048
      issuerRef:
        kind: Issuer
        name: test-issuer
      keystores:
        jks:
          create: true
          passwordSecretRef:
            key: password-key
            name: jks-password-secret
      secretName: wildcard-cert
    EOF
  )
  depends_on = [kubernetes_manifest.final_issuer]
}

data "kubernetes_secret" "myca" {
  metadata {
    name = "root-ca-svc-secret"
    namespace = "${var.namespace}"
  }

  depends_on = [kubernetes_manifest.certificate_wildcard]
}