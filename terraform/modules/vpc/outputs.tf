output "vpc_id" {
  description = "ID of the VPC"
  value       = google_compute_network.main.id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.main.name
}

output "prod_frontend_subnet_id" {
  description = "ID of the production frontend subnet"
  value       = google_compute_subnetwork.prod_frontend.id
}

output "prod_frontend_subnet_name" {
  description = "Name of the production frontend subnet"
  value       = google_compute_subnetwork.prod_frontend.name
}

output "prod_backend_subnet_id" {
  description = "ID of the production backend subnet"
  value       = google_compute_subnetwork.prod_backend.id
}

output "prod_backend_subnet_name" {
  description = "Name of the production backend subnet"
  value       = google_compute_subnetwork.prod_backend.name
}

output "prod_db_subnet_id" {
  description = "ID of the production DB subnet"
  value       = google_compute_subnetwork.prod_db.id
}

output "prod_db_subnet_name" {
  description = "Name of the production DB subnet"
  value       = google_compute_subnetwork.prod_db.name
}

output "staging_frontend_subnet_id" {
  description = "ID of the staging frontend subnet"
  value       = google_compute_subnetwork.staging_frontend.id
}

output "staging_frontend_subnet_name" {
  description = "Name of the staging frontend subnet"
  value       = google_compute_subnetwork.staging_frontend.name
}

output "staging_backend_subnet_id" {
  description = "ID of the staging backend subnet"
  value       = google_compute_subnetwork.staging_backend.id
}

output "staging_backend_subnet_name" {
  description = "Name of the staging backend subnet"
  value       = google_compute_subnetwork.staging_backend.name
}

output "staging_db_subnet_id" {
  description = "ID of the staging DB subnet"
  value       = google_compute_subnetwork.staging_db.id
}

output "staging_db_subnet_name" {
  description = "Name of the staging DB subnet"
  value       = google_compute_subnetwork.staging_db.name
}

output "shared_infra_subnet_id" {
  description = "ID of the shared infrastructure subnet"
  value       = google_compute_subnetwork.shared_infra.id
}

output "shared_infra_subnet_name" {
  description = "Name of the shared infrastructure subnet"
  value       = google_compute_subnetwork.shared_infra.name
}

output "router_id" {
  description = "ID of the Cloud Router"
  value       = google_compute_router.main.id
}

output "nat_id" {
  description = "ID of the Cloud NAT"
  value       = google_compute_router_nat.main.id
}
