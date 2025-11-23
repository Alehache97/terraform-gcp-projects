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
# DISCO ADICIONAL DESDE SNAPSHOT
# ----------------------------
resource "google_compute_disk" "disco2" {
  name     = "disco2-vm-red-restaurado"
  type     = "pd-standard"
  zone     = var.zone
  size     = var.disk_size
  snapshot = var.disk_snapshot
}

# ----------------------------
# MÁQUINA VIRTUAL CON IMAGEN PERSONALIZADA Y DISCO ADICIONAL
# ----------------------------
resource "google_compute_instance" "vm_red" {
  name         = "vm-ejemplo2"
  machine_type = var.machine_type

  # Disco principal (boot) desde imagen personalizada
  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.disk_size
    }
  }

  # Disco adicional restaurado desde snapshot
  attached_disk {
    source = google_compute_disk.disco2.id
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
