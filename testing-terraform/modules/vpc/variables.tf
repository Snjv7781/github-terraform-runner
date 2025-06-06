variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"

}

variable "vpc_name" {
  description = "name of the vpc"
  type = string
  default = "sanjeev-prod-vpc"
}