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
    EOF
  )
  depends_on = [kubernetes_manifest.cluster_self_issuer]
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
        - "*.localhost"
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