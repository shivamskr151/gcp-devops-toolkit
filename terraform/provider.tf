provider "google" {
  project     = local.config.project.id
  region      = local.config.project.region
  credentials = file("${path.module}/../terraform-sa-key.json")
}

locals {
  # Default to config.yaml, but can be overridden with TF_VAR_config_file
  config_file = var.config_file
  config      = yamldecode(file("${path.module}/${local.config_file}"))
}

