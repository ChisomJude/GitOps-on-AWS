output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "codecommit_repository_http_url" {
  description = "The HTTP URL of the CodeCommit repository"
  value       = aws_codecommit_repository.repo.clone_url_http
}

output "codecommit_repository_ssh_url" {
  description = "The SSH URL of the CodeCommit repository"
  value       = aws_codecommit_repository.repo.clone_url_ssh
}
