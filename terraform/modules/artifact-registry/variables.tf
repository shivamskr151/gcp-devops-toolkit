variable "repositories" {
  description = "List of Artifact Registry repositories"
  type = list(object({
    name        = string
    description = string
    format      = string
    location    = string
  }))
}

variable "labels" {
  description = "Labels for repositories"
  type        = map(string)
  default     = {}
}

