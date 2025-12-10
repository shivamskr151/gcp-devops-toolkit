# Step 2: GKE Clusters - One cluster for production, one for staging
# Each cluster has both frontend and backend node pools

# Production Cluster (uses prod-backend-subnet)
module "gke_prod" {
  source = "./modules/gke"

  cluster_name = local.config.gke.clusters.prod.name
  project_id   = local.config.project.id
  region       = local.config.gke.clusters.prod.region
  network      = module.vpc.vpc_name
  subnetwork   = module.vpc.prod_backend_subnet_name  # Uses prod-backend-subnet

  enable_private_nodes    = local.config.gke.clusters.prod.enable_private_nodes
  enable_private_endpoint = local.config.gke.clusters.prod.enable_private_endpoint
  master_ipv4_cidr_block = local.config.gke.clusters.prod.master_ipv4_cidr_block
  master_authorized_networks = length(local.config.gke.clusters.prod.master_authorized_networks) > 0 ? [
    for net in local.config.gke.clusters.prod.master_authorized_networks : {
      cidr_block   = net.cidr_block
      display_name = net.display_name
    }
  ] : []

  release_channel = local.config.gke.clusters.prod.release_channel

  node_labels = {
    environment = "production"
    cluster     = "gke-prod"
  }

  resource_labels = {
    environment = "production"
    managed-by  = "terraform"
  }

  node_pools = {
    for pool_key, pool_config in local.config.gke.clusters.prod.node_pools : pool_key => {
      name              = pool_config.name
      subnetwork       = module.vpc.prod_backend_subnet_name  # All pools use cluster subnet
      initial_node_count = pool_config.initial_node_count
      min_node_count    = pool_config.min_node_count
      max_node_count    = pool_config.max_node_count
      machine_type      = pool_config.machine_type
      disk_size_gb      = pool_config.disk_size_gb
      disk_type         = pool_config.disk_type
      preemptible       = false
      labels            = pool_config.labels
    }
  }

  network_dependency = module.vpc.vpc_id
}

# Staging Cluster (uses staging-backend-subnet)
module "gke_staging" {
  source = "./modules/gke"

  cluster_name = local.config.gke.clusters.staging.name
  project_id   = local.config.project.id
  region       = local.config.gke.clusters.staging.region
  network      = module.vpc.vpc_name
  subnetwork   = module.vpc.staging_backend_subnet_name  # Uses staging-backend-subnet

  enable_private_nodes    = local.config.gke.clusters.staging.enable_private_nodes
  enable_private_endpoint = local.config.gke.clusters.staging.enable_private_endpoint
  master_ipv4_cidr_block = local.config.gke.clusters.staging.master_ipv4_cidr_block
  master_authorized_networks = length(local.config.gke.clusters.staging.master_authorized_networks) > 0 ? [
    for net in local.config.gke.clusters.staging.master_authorized_networks : {
      cidr_block   = net.cidr_block
      display_name = net.display_name
    }
  ] : []

  release_channel = local.config.gke.clusters.staging.release_channel

  node_labels = {
    environment = "staging"
    cluster     = "gke-staging"
  }

  resource_labels = {
    environment = "staging"
    managed-by  = "terraform"
  }

  node_pools = {
    for pool_key, pool_config in local.config.gke.clusters.staging.node_pools : pool_key => {
      name              = pool_config.name
      subnetwork       = module.vpc.staging_backend_subnet_name  # All pools use cluster subnet
      initial_node_count = pool_config.initial_node_count
      min_node_count    = pool_config.min_node_count
      max_node_count    = pool_config.max_node_count
      machine_type      = pool_config.machine_type
      disk_size_gb      = pool_config.disk_size_gb
      disk_type         = pool_config.disk_type
      preemptible       = false
      labels            = pool_config.labels
    }
  }

  network_dependency = module.vpc.vpc_id
}
