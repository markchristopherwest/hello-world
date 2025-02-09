
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "${module.eks.cluster_arn}"
}
resource "kubernetes_role_binding" "example" {
  metadata {
    name      = "terraform-example"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "admin"
  }
  subject {
    kind      = "User"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}
# resource "kubernetes_namespace" "apps" {
#   metadata {
#     name = "apps"
#   }
# }

# resource "kubernetes_secret" "example" {
#   metadata {
#     name = "frontend-config"
#     namespace = "apps"
#   }

#   data = {
#     DH_HOST = "${aws_instance.mongo.public_dns}"
#     DB_NAME = "hello-world"
#     DB_PORT = "27017"
#     DB_PASS = "dude"
#     DB_USER = "dude"
#   }

#   type = "kubernetes.io/opaque"
# }

# resource "kubernetes_deployment" "hello_world" {
#   metadata {
#     name = "hello-world"
#     namespace = kubernetes_namespace.apps.metadata.0.name
#     labels = {
#       test = random_pet.example.id
#     }
#   }

#   spec {
#     replicas = 3

#     selector {
#       match_labels = {
#         test = random_pet.example.id
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           test = random_pet.example.id
#         }
#       }

#       spec {
#         container {
#           image = "nginx:1.21.6"
#           name  = "example"

#           resources {
#             limits = {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }

#           liveness_probe {
#             http_get {
#               path = "/"
#               port = 80

#               http_header {
#                 name  = "X-Custom-Header"
#                 value = "Awesome"
#               }
#             }

#             initial_delay_seconds = 3
#             period_seconds        = 3
#           }
#         }
#       }
#     }
#   }
# }

# # resource "kubernetes_service" "example" {
# #   metadata {
# #     name = "hello-world"
# #     namespace = kubernetes_namespace.apps.metadata.0.name
# #   }
# #   spec {
# #     selector = {
# #       app = kubernetes_pod.example.metadata.0.labels.app
# #     }
# #     session_affinity = "ClientIP"
# #     port {
# #       port        = 3000
# #       target_port = 80
# #     }

# #     type = "LoadBalancer"
# #   }
# # }

# # resource "kubernetes_pod" "example" {
# #   metadata {
# #     name = "terraform-example"
# #     namespace = kubernetes_namespace.apps.metadata.0.name
# #     labels = {
# #       name = "hello-world"
# #     }
# #   }

# #   spec {
# #     container {
# #       image = "nginx:1.21.6"
# #       name  = "example"
# #     }
# #   }
# # }