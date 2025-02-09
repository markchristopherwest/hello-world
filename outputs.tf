# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

# output "region" {
#   description = "AWS region"
#   value       = var.region
# }

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# output "subnet_cidr_blocks" {
#   description = "Public Subnet IDs for ec2 VM to bind to"
#   value = [for s in data.aws_subnet.example : s.id][0]
# }

output "ec2_hostname" {
  description = "public hostname for you to connect to."
  value = aws_instance.mongo.public_dns
}

output "s3_bucket_object_storage_domain_name" {
  description = "name of the s3 bucket where Mongo backups go"
  value = aws_s3_bucket.mongo.bucket_domain_name
}

output "connect_ssh" {
  description = "SSH connection string"
  value       = <<EOT

ssh -i "${aws_key_pair.demo_ec2_ssh_key_pair.key_name}.pem" ubuntu@${aws_instance.mongo.public_dns}

EOT
}

output "connect_mongo" {
  description = "Mongo connection string"
  value       = <<EOT

mongosh "mongodb://dude:changeme@${aws_instance.mongo.public_dns}:27017/hello_world"
EOT
}

output "deploy_helm" {
  description = "Helm installation string"
  value       = <<EOT

helm install --set DB_HOST=${aws_instance.mongo.public_dns} frontend markchristopherwest/hello-world-chart
EOT
}

output "deploy_manifest" {
  description = "Helm installation string"
  value       = <<EOT

SERVICE_NAME=frontend NS=apps  DB_HOST=${aws_instance.mongo.public_dns} DB_NAME=hello_world envsubst < k8s-service-example.yml | kubectl apply -f -
EOT
}