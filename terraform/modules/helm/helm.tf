resource "helm_release" "nginx" {
  name       = "nginx"
  chart      = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  version    = "15.0.0"

  set {
    name  = "service.type"
    value = "NodePort"
  }
}

