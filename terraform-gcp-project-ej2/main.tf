# ----------------------------
# RED PERSONALIZADA
# ----------------------------
resource "google_compute_network" "red_personalizada" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subred_personalizada" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_range
  region        = var.region
  network       = google_compute_network.red_personalizada.id
}

# ----------------------------
# REGLA DE FIREWALL PARA SSH
# ----------------------------
resource "google_compute_firewall" "ssh_firewall" {
  name    = "allow-ssh"
  network = google_compute_network.red_personalizada.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["terraform", "vm-ejemplo2"]
}

# ----------------------------
# MÁQUINA VIRTUAL CONECTADA A LA RED
# ----------------------------
resource "google_compute_instance" "vm_red" {
  name         = "vm-ejemplo2"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size
    }
  }

  network_interface {
    network    = google_compute_network.red_personalizada.id
    subnetwork = google_compute_subnetwork.subred_personalizada.id
    access_config {} # IP pública para conexión SSH
  }

  metadata = {
    ssh-keys = "macale:${file(var.ssh_key_path)}"
  }

  tags = ["terraform", "vm-ejemplo2"]
}
