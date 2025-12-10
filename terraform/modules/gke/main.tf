# GKE Cluster Module
resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  # Deletion protection - set to false to allow cluster deletion
  deletion_protection = false

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Master authorized networks
  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Release channel
  release_channel {
    channel = var.release_channel
  }

  # Network policy
  network_policy {
    enabled = true
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # IP allocation policy - use subnet secondary ranges
  # IP aliases are automatically enabled when secondary ranges are specified
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name  = "services"
  }

  # Vertical Pod Autoscaling
  vertical_pod_autoscaling {
    enabled = true
  }

  # Maintenance window - Optional, can be configured later via GCP Console
  # Commented out due to GKE validation requirements (must be within 32 days)
  # Uncomment and set appropriate dates if needed
  # maintenance_policy {
  #   recurring_window {
  #     start_time = "2025-01-04T20:30:00Z"  # Sunday 2 AM IST
  #     end_time   = "2025-01-05T00:30:00Z"  # Sunday 6 AM IST
  #     recurrence = "FREQ=WEEKLY;BYDAY=SA"
  #   }
  # }

  # Logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Resource labels
  resource_labels = var.resource_labels

  depends_on = [var.network_dependency]

  # Lifecycle rule to ensure node pools are deleted before cluster
  lifecycle {
    create_before_destroy = false
  }
}

# Node pools are now defined in node-pool.tf

