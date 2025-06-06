provider "google" {
  project = var.project_id
  region  = var.region

}

module "vpc" {
  source     = "./modules/vpc"
  project_id = var.project_id
  region     = var.region

}

module "gke" {
  source     = "./modules/gke"
  project_id = var.project_id
  region     = var.region
  network    = module.vpc.network_id        # <-- From vpc module outputs.tf
  subnetwork = module.vpc.private_subnet_id # <-- From vpc module outputs.tf
  vpc_name   = var.vpc_name
}
module "github-runner" {
  source          = "./modules/github-runner"
  zone            = var.zone
  subnet          = module.vpc.private_subnet_id
  github_repo_url = var.github_repo_url
  runner_token    = var.runner_token
  vpc_name        = var.vpc_name
}