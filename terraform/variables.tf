variable "config_file" {
  description = "Path to the configuration YAML file (relative to terraform directory)"
  type        = string
  default     = "config.yaml"
}

variable "create_artifact_registry" {
  description = "Whether to create Artifact Registry repositories (requires artifactregistry.repositories.create permission)"
  type        = bool
  default     = true
}

