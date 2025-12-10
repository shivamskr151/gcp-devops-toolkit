variable "network" {
  description = "VPC network name"
  type        = string
}

variable "rules" {
  description = "List of firewall rules"
  type = list(object({
    name         = string
    description  = string
    direction    = string
    priority     = number
    source_ranges = list(string)
    target_tags  = list(string)
    allowed      = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
    denied = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
}

