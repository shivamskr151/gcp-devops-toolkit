output "repository_urls" {
  description = "URLs of the Artifact Registry repositories"
  value = {
    for k, v in google_artifact_registry_repository.repositories : k => v.name
  }
}

output "repository_ids" {
  description = "IDs of the Artifact Registry repositories"
  value = {
    for k, v in google_artifact_registry_repository.repositories : k => v.id
  }
}

