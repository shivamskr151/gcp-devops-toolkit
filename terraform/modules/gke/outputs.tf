output "cluster_id" {
  description = "ID of the GKE cluster"
  value       = google_container_cluster.main.id
}

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster"
  value       = google_container_cluster.main.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate for the GKE cluster"
  value       = google_container_cluster.main.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "node_pool_ids" {
  description = "IDs of the node pools"
  value = {
    for k, v in google_container_node_pool.pools : k => v.id
  }
}

