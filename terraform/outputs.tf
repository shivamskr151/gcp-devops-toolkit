# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "VPC Name"
  value       = module.vpc.vpc_name
}

output "prod_frontend_subnet_name" {
  description = "Production Frontend Subnet Name"
  value       = module.vpc.prod_frontend_subnet_name
}

output "prod_backend_subnet_name" {
  description = "Production Backend Subnet Name"
  value       = module.vpc.prod_backend_subnet_name
}

output "prod_db_subnet_name" {
  description = "Production DB Subnet Name"
  value       = module.vpc.prod_db_subnet_name
}

output "staging_frontend_subnet_name" {
  description = "Staging Frontend Subnet Name"
  value       = module.vpc.staging_frontend_subnet_name
}

output "staging_backend_subnet_name" {
  description = "Staging Backend Subnet Name"
  value       = module.vpc.staging_backend_subnet_name
}

output "staging_db_subnet_name" {
  description = "Staging DB Subnet Name"
  value       = module.vpc.staging_db_subnet_name
}

output "shared_infra_subnet_name" {
  description = "Shared Infrastructure Subnet Name"
  value       = module.vpc.shared_infra_subnet_name
}

# GKE Outputs
output "gke_prod_cluster_name" {
  description = "GKE Production Cluster Name"
  value       = module.gke_prod.cluster_name
}

output "gke_prod_cluster_endpoint" {
  description = "GKE Production Cluster Endpoint"
  value       = module.gke_prod.cluster_endpoint
  sensitive   = true
}

output "gke_staging_cluster_name" {
  description = "GKE Staging Cluster Name"
  value       = module.gke_staging.cluster_name
}

output "gke_staging_cluster_endpoint" {
  description = "GKE Staging Cluster Endpoint"
  value       = module.gke_staging.cluster_endpoint
  sensitive   = true
}

# Artifact Registry Outputs
output "artifact_registry_repositories" {
  description = "Artifact Registry Repository URLs"
  value       = var.create_artifact_registry ? module.artifact_registry[0].repository_urls : {}
}
