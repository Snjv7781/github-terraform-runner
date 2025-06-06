provider "google" {
  project = var.project_id
  region  = var.region
}

# # Get the existing VPC (from vpc module)
# data "google_compute_network" "vpc" {
#   name    = var.vpc_name
#   project = var.project_id
# }

# # Get the existing private subnet from VPC module
# data "google_compute_subnetwork" "private_subnet" {
#   name    = "private-subnet"
#   region  = var.region
#   project = var.project_id
# }

# Create a new subnet for GKE (only for pods/services IP allocation)
resource "google_compute_subnetwork" "gke_subnet" {
  name                     = "gke-subnet"
  ip_cidr_range            = "10.20.0.0/16"  # Make sure this doesn't overlap
  region                   = var.region
  network                  = var.network
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.21.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.22.0.0/20"
  }
}

# Private GKE Cluster
resource "google_container_cluster" "private_cluster" {
  name     = "private-gke-cluster"
  location = var.region
  deletion_protection = false
  network = var.network
  subnetwork = var.subnetwork
  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
    master_global_access_config {
    enabled = true
  }
  }

  ip_allocation_policy {
    # use_ip_aliases = true
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "service-range"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "10.10.0.0/16"
      display_name = "cloud shell"
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  enable_legacy_abac = false

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# Node pool for private cluster
resource "google_container_node_pool" "private_nodes" {
  name       = "private-node-pool"
  cluster    = google_container_cluster.private_cluster.name
  location   = var.region
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    disk_size_gb = 50
    image_type   = "COS_CONTAINERD"
    labels = {
      env = "prod"
    }
    tags = ["private-node"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
  
  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}