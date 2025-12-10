# VPC Module
resource "google_compute_network" "main" {
  name                    = var.vpc_name
  description             = var.vpc_description
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode           = var.routing_mode

  # Lifecycle rule to ensure subnets and dependent resources are deleted first
  lifecycle {
    create_before_destroy = false
  }
}

# Production Frontend Subnet (Public)
resource "google_compute_subnetwork" "prod_frontend" {
  name          = var.prod_frontend_subnet.name
  description   = var.prod_frontend_subnet.description
  ip_cidr_range = var.prod_frontend_subnet.cidr
  region        = var.prod_frontend_subnet.region
  network       = google_compute_network.main.id
  
  # Secondary IP ranges for GKE pods and services (prod-frontend specific)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/20"  # prod-frontend-pods-range
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.20.16.0/20"  # prod-frontend-services-range
  }
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  depends_on = [google_compute_network.main]
}

# Production Backend Subnet (Private)
resource "google_compute_subnetwork" "prod_backend" {
  name          = var.prod_backend_subnet.name
  description   = var.prod_backend_subnet.description
  ip_cidr_range = var.prod_backend_subnet.cidr
  region        = var.prod_backend_subnet.region
  network       = google_compute_network.main.id
  private_ip_google_access = true
  
  # Secondary IP ranges for GKE pods and services (prod-backend specific)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.32.0/20"  # prod-backend-pods-range
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.20.48.0/20"  # prod-backend-services-range
  }
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  depends_on = [google_compute_network.main]
}

# Production DB Subnet (Private)
resource "google_compute_subnetwork" "prod_db" {
  name          = var.prod_db_subnet.name
  description   = var.prod_db_subnet.description
  ip_cidr_range = var.prod_db_subnet.cidr
  region        = var.prod_db_subnet.region
  network       = google_compute_network.main.id
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  depends_on = [google_compute_network.main]
}

# Staging Frontend Subnet (Public)
resource "google_compute_subnetwork" "staging_frontend" {
  name          = var.staging_frontend_subnet.name
  description   = var.staging_frontend_subnet.description
  ip_cidr_range = var.staging_frontend_subnet.cidr
  region        = var.staging_frontend_subnet.region
  network       = google_compute_network.main.id
  
  # Secondary IP ranges for GKE pods and services (staging-frontend specific)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.21.32.0/20"  # staging-frontend-pods-range
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.21.48.0/20"  # staging-frontend-services-range
  }
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  depends_on = [google_compute_network.main]
}

# Staging Backend Subnet (Private)
resource "google_compute_subnetwork" "staging_backend" {
  name          = var.staging_backend_subnet.name
  description   = var.staging_backend_subnet.description
  ip_cidr_range = var.staging_backend_subnet.cidr
  region        = var.staging_backend_subnet.region
  network       = google_compute_network.main.id
  private_ip_google_access = true
  
  # Secondary IP ranges for GKE pods and services (staging-backend specific)
  # Note: These ranges are already set in the existing subnetwork and cannot be modified
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.21.0.0/20"  # staging-backend-pods-range
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.21.16.0/20"  # staging-backend-services-range
  }
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  depends_on = [google_compute_network.main]
}

# Staging DB Subnet (Private)
resource "google_compute_subnetwork" "staging_db" {
  name          = var.staging_db_subnet.name
  description   = var.staging_db_subnet.description
  ip_cidr_range = var.staging_db_subnet.cidr
  region        = var.staging_db_subnet.region
  network       = google_compute_network.main.id
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  depends_on = [google_compute_network.main]
}

# Shared Infrastructure Subnet (Private) - NAT, Cloud Router, CI/CD, Monitoring
resource "google_compute_subnetwork" "shared_infra" {
  name          = var.shared_infra_subnet.name
  description   = var.shared_infra_subnet.description
  ip_cidr_range = var.shared_infra_subnet.cidr
  region        = var.shared_infra_subnet.region
  network       = google_compute_network.main.id
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  depends_on = [google_compute_network.main]
}

# Cloud Router for NAT (in shared-infra-subnet)
resource "google_compute_router" "main" {
  name    = var.router_name
  region  = var.region
  network = google_compute_network.main.id
  
  bgp {
    asn = 64514
  }

  # Lifecycle rule to ensure NAT is deleted before Router
  lifecycle {
    create_before_destroy = false
  }
}

# Cloud NAT (in shared-infra-subnet)
resource "google_compute_router_nat" "main" {
  name                               = var.nat_name
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
  
  depends_on = [google_compute_router.main]

  # Lifecycle rule to ensure NAT is deleted before Router
  lifecycle {
    create_before_destroy = false
  }
}
