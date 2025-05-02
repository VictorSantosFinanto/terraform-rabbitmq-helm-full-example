provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

# VPC
resource "google_compute_network" "vpc_network" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id

  private_ip_google_access = true
}

# Cloud Router
resource "google_compute_router" "router" {
  name    = "gke-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
}

# Cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = "gke-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Cluster GKE privado
resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = var.region

  networking_mode          = "VPC_NATIVE"
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {}

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks (for testing)"
    }
  }
}

# Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name     = "node-pool"
  location = var.region
  cluster  = google_container_cluster.primary.name

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  initial_node_count = 1
}
