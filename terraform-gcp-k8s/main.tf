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
  initial_node_count       = 1
}

# Node pool
resource "google_container_node_pool" "node_pool" {
  name     = "node-pool"
  location = "europe-west1-b"
  cluster  = google_container_cluster.gke_cluster.name

  # Número inicial de nodos (puede escalar a 0 automáticamente si no hay carga)
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # Autoscaling configurado según tu solicitud
  autoscaling {
    min_node_count = 0
    max_node_count = 30
  }
}
