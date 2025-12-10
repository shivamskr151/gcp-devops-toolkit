# Artifact Registry Module
resource "google_artifact_registry_repository" "repositories" {
  for_each = {
    for repo in var.repositories : repo.name => repo
  }

  location      = each.value.location
  repository_id = each.value.name
  description   = each.value.description
  format        = each.value.format

  labels = var.labels

  # Lifecycle rule to allow deletion even if repository contains images
  lifecycle {
    create_before_destroy = false
  }
}

