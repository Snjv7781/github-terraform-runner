variable "zone" {}
# variable "public_subnet_id" {}
variable "github_repo_url" {}
variable "runner_token" {}
# variable "service_account_email" {}
# variable "private_subnet_id" {}
variable "subnet" {
  description = "subnet to launch the github-runner VM in"
  type = string
}
variable "runner_version" {
  description = "Version of GitHub Actions Runner"
  type        = string
  default     = "2.324.0"
}
variable "vpc_name" {
  description = "name of the vpc"
  type = string
}
