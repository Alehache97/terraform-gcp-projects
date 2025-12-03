#################################################
# RED Y CLUSTER GKE
#################################################

# Red VPC
resource "google_compute_network" "vpc_gke" {
  name                    = "vpc-gke"
  auto_create_subnetworks = false
}

# Subred
resource "google_compute_subnetwork" "subnet_gke" {
  name          = "subnet-gke"
  ip_cidr_range = "10.10.0.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_gke.id
}

# Router
resource "google_compute_router" "router_gke" {
  name    = "router-gke"
  region  = "europe-west1"
  network = google_compute_network.vpc_gke.id
}

# NAT
resource "google_compute_router_nat" "nat_gke" {
  name                               = "nat-gke"
  router                             = google_compute_router.router_gke.name
  region                             = "europe-west1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Cluster principal
resource "google_container_cluster" "gke_cluster" {
  name                     = "gke-cluster"
  location                 = "europe-west1-b"
  network                  = google_compute_network.vpc_gke.id
  subnetwork               = google_compute_subnetwork.subnet_gke.id
  remove_default_node_pool = true
  deletion_protection      = false

  # Obligatorio por la API
  initial_node_count       = 1
}

# Node pool principal (3 nodos, 50 GB, autoscaling)
resource "google_container_node_pool" "node_pool" {
  name     = "node-pool"
  location = "europe-west1-b"
  cluster  = google_container_cluster.gke_cluster.name

  node_count = 3

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    min_node_count = 3
    max_node_count = 30
  }
}
