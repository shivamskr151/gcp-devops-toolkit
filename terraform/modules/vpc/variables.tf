variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_description" {
  description = "Description of the VPC"
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Whether to auto-create subnetworks"
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "Routing mode for the VPC"
  type        = string
  default     = "REGIONAL"
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "prod_frontend_subnet" {
  description = "Production frontend subnet configuration"
  type = object({
    name        = string
    description = string
    cidr        = string
    region      = string
  })
}

variable "prod_backend_subnet" {
  description = "Production backend subnet configuration"
  type = object({
    name        = string
    description = string
    cidr        = string
    region      = string
  })
}

variable "prod_db_subnet" {
  description = "Production DB subnet configuration"
  type = object({
    name        = string
    description = string
    cidr        = string
    region      = string
  })
}

variable "staging_frontend_subnet" {
  description = "Staging frontend subnet configuration"
  type = object({
    name        = string
    description = string
    cidr        = string
    region      = string
  })
}

variable "staging_backend_subnet" {
  description = "Staging backend subnet configuration"
  type = object({
    name        = string
    description = string
    cidr        = string
    region      = string
  })
}

variable "staging_db_subnet" {
  description = "Staging DB subnet configuration"
  type = object({
    name        = string
    description = string
    cidr        = string
    region      = string
  })
}

variable "shared_infra_subnet" {
  description = "Shared infrastructure subnet configuration"
  type = object({
    name        = string
    description = string
    cidr        = string
    region      = string
  })
}

variable "nat_name" {
  description = "Name of the NAT gateway"
  type        = string
}

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}
