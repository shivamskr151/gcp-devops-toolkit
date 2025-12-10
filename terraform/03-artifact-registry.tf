# Step 3: Google Artifact Registry (GAR)
# Note: Requires artifactregistry.repositories.create permission
# If you get permission errors, grant the service account:
# roles/artifactregistry.admin or roles/artifactregistry.writer
module "artifact_registry" {
  source = "./modules/artifact-registry"
  count  = var.create_artifact_registry ? 1 : 0

  repositories = [
    for repo in local.config.artifact_registry.repositories : {
      name        = repo.name
      description = repo.description
      format      = repo.format
      location    = repo.location
    }
  ]

  labels = {
    managed-by = "terraform"
    environment = "shared"
  }
}

