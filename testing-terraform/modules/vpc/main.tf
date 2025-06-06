provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}


resource "google_compute_subnetwork" "public_subnet" {
  name          = "pub-sub-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.self_link
  project       = var.project_id
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "pri-sub-1"
  ip_cidr_range = "10.50.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.self_link
  project       = var.project_id
  private_ip_google_access = true

  secondary_ip_range {
    range_name = "pods-range"
    ip_cidr_range = "10.60.0.0/16"
  }

  secondary_ip_range {
    range_name = "service-range"
    ip_cidr_range = "10.70.0.0/20"
  }
}


resource "google_compute_router" "router" {
  name    = "nat-router-1"
  region  = var.region
  network = var.vpc_name
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "cloud-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-ingress"
  network = google_compute_network.vpc.self_link  

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] 

  description = "Allow SSH from anywhere to VMs with the allow-ssh tag"
}
