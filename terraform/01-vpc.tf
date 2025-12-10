# Step 1: VPC with Environment-Specific Subnets, Routing, and NAT
module "vpc" {
  source = "./modules/vpc"

  vpc_name         = local.config.vpc.name
  vpc_description  = local.config.vpc.description
  auto_create_subnetworks = local.config.vpc.auto_create_subnetworks
  routing_mode     = local.config.vpc.routing_mode
  region           = local.config.project.region

  prod_frontend_subnet = {
    name        = local.config.vpc.subnets.prod_frontend.name
    description = local.config.vpc.subnets.prod_frontend.description
    cidr        = local.config.vpc.subnets.prod_frontend.cidr
    region      = local.config.vpc.subnets.prod_frontend.region
  }

  prod_backend_subnet = {
    name        = local.config.vpc.subnets.prod_backend.name
    description = local.config.vpc.subnets.prod_backend.description
    cidr        = local.config.vpc.subnets.prod_backend.cidr
    region      = local.config.vpc.subnets.prod_backend.region
  }

  prod_db_subnet = {
    name        = local.config.vpc.subnets.prod_db.name
    description = local.config.vpc.subnets.prod_db.description
    cidr        = local.config.vpc.subnets.prod_db.cidr
    region      = local.config.vpc.subnets.prod_db.region
  }

  staging_frontend_subnet = {
    name        = local.config.vpc.subnets.staging_frontend.name
    description = local.config.vpc.subnets.staging_frontend.description
    cidr        = local.config.vpc.subnets.staging_frontend.cidr
    region      = local.config.vpc.subnets.staging_frontend.region
  }

  staging_backend_subnet = {
    name        = local.config.vpc.subnets.staging_backend.name
    description = local.config.vpc.subnets.staging_backend.description
    cidr        = local.config.vpc.subnets.staging_backend.cidr
    region      = local.config.vpc.subnets.staging_backend.region
  }

  staging_db_subnet = {
    name        = local.config.vpc.subnets.staging_db.name
    description = local.config.vpc.subnets.staging_db.description
    cidr        = local.config.vpc.subnets.staging_db.cidr
    region      = local.config.vpc.subnets.staging_db.region
  }

  shared_infra_subnet = {
    name        = local.config.vpc.subnets.shared_infra.name
    description = local.config.vpc.subnets.shared_infra.description
    cidr        = local.config.vpc.subnets.shared_infra.cidr
    region      = local.config.vpc.subnets.shared_infra.region
  }

  nat_name    = local.config.nat.name
  router_name = local.config.nat.router_name
}

# Firewall Rules
module "firewall" {
  source = "./modules/firewall"

  network = module.vpc.vpc_name

  rules = [
    for rule in local.config.firewall_rules : {
      name         = rule.name
      description  = rule.description
      direction    = rule.direction
      priority     = rule.priority
      source_ranges = rule.source_ranges
      target_tags  = []
      allowed      = rule.allowed
      denied       = null
    }
  ]

  depends_on = [module.vpc]
}
