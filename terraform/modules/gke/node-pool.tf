# Node Pool Module - Supports multiple node pools in different subnets
resource "google_container_node_pool" "pools" {
  for_each = var.node_pools

  name       = "${var.cluster_name}-${each.value.name}"
  location   = var.region
  cluster    = google_container_cluster.main.name
  node_count = each.value.initial_node_count

  autoscaling {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Configure network - use subnet's secondary ranges
  network_config {
    create_pod_range = false
    pod_range       = "pods"
  }

  node_config {
    preemptible     = each.value.preemptible != null ? each.value.preemptible : false
    machine_type    = each.value.machine_type
    disk_size_gb    = each.value.disk_size_gb
    disk_type       = each.value.disk_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    # Note: subnetwork cannot be specified in node_config
    # All node pools in a cluster use the cluster's subnet

    labels = merge(
      var.node_labels,
      each.value.labels != null ? each.value.labels : {}
    )

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded nodes
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  depends_on = [google_container_cluster.main]

  # Lifecycle rule to ensure node pools are deleted before cluster
  lifecycle {
    create_before_destroy = false
  }
}

