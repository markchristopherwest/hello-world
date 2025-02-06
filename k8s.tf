
# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "arn:aws:eks:us-west-2:807078899029:cluster/ideal-turtle"
# }

# resource "kubernetes_namespace" "apps" {
#   metadata {
#     name = "apps"
#   }
# }

# # resource "kubernetes_deployment" "hello_world" {
# #   metadata {
# #     name = "hello-world"
# #     namespace = kubernetes_namespace.apps.metadata.0.name
# #     labels = {
# #       test = random_pet.example.id
# #     }
# #   }

# #   spec {
# #     replicas = 3

# #     selector {
# #       match_labels = {
# #         test = random_pet.example.id
# #       }
# #     }

# #     template {
# #       metadata {
# #         labels = {
# #           test = random_pet.example.id
# #         }
# #       }

# #       spec {
# #         container {
# #           image = "nginx:1.21.6"
# #           name  = "example"

# #           resources {
# #             limits = {
# #               cpu    = "0.5"
# #               memory = "512Mi"
# #             }
# #             requests = {
# #               cpu    = "250m"
# #               memory = "50Mi"
# #             }
# #           }

# #           liveness_probe {
# #             http_get {
# #               path = "/"
# #               port = 80

# #               http_header {
# #                 name  = "X-Custom-Header"
# #                 value = "Awesome"
# #               }
# #             }

# #             initial_delay_seconds = 3
# #             period_seconds        = 3
# #           }
# #         }
# #       }
# #     }
# #   }
# # }

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