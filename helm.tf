# resource "helm_release" "nginx_ingress" {
#   name       = "${random_pet.example.id}-nginx-ingress"
#   namespace  = kubernetes_namespace.example.metadata.0.name
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
# #   version    = local.vault_helm_release_version   
#   set {
#     name  = "global.certs.certName"
#     value = "vault-tls-${each.key}"
#   }
# #   depends_on = [
# #     # kubernetes_secret.tls_ca, 
# #     kubernetes_secret.vault_license,
# #     kubernetes_namespace.example
# #   ]
# }