variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "vpc_name" {
  type    = string
  default = "sanjeev-prod-vpc"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "github_repo_url" {
  type = string
}

variable "runner_token" {
  type      = string
  sensitive = true
}

# variable "gcp_credentials" {
#   type        = string
#   description = "GCP credentials in JSON format"
#   sensitive   = true
# }