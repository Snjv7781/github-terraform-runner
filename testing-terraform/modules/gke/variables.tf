variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "network" {
  description = "Subnetwork name"
  type = string
}

variable "subnetwork" {
  description = "Subnetwork name"
  type = string
}
variable "vpc_name" {
  description = "name of the vpc"
  type = string
  default = "sanjeev-prod-vpc"
}