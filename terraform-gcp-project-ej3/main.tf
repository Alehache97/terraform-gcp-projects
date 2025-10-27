#############################################
# REDES Y SUBREDES
#############################################

resource "google_compute_network" "vpc_principal" {
  name                    = "vpc-principal"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subred_publica" {
  name          = "subred-publica"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_principal.id
}

resource "google_compute_subnetwork" "subred_privada" {
  name          = "subred-privada"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_principal.id
}

#############################################
# FIREWALLS
#############################################

# SSH público solo al bastión
resource "google_compute_firewall" "allow_ssh_public" {
  name    = "allow-ssh-public"
  network = google_compute_network.vpc_principal.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.my_ip]
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "allow_ssh_from_bastion" {
  name    = "allow-ssh-from-bastion"
  network = google_compute_network.vpc_principal.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.1.0/24"]  # subred del bastión
  target_tags   = ["privada"]      # cliente y servidor
}

# Comunicación interna solo entre máquinas privadas (cliente y servidor)
resource "google_compute_firewall" "allow_internal_private" {
  name    = "allow-internal-private"
  network = google_compute_network.vpc_principal.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.2.0/24"] # solo subred privada
  target_tags   = ["privada"]     # aplica solo a cliente y servidor
}


#############################################
# ROUTER + NAT PARA SUBRED PRIVADA
#############################################

resource "google_compute_router" "router" {
  name    = "vpc-router"
  network = google_compute_network.vpc_principal.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "vpc-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

#############################################
# MÁQUINA BASTIÓN (pública)
#############################################

resource "google_compute_instance" "bastion" {
  name         = "vm-bastion"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size
    }
  }

  network_interface {
    network    = google_compute_network.vpc_principal.id
    subnetwork = google_compute_subnetwork.subred_publica.id
    access_config {} # IP pública para SSH
  }

  metadata = {
    ssh-keys = "macale:${file(var.ssh_key_path)}"
  }

  tags = ["bastion"]
}

#############################################
# MÁQUINA SERVIDOR (privada)
#############################################

resource "google_compute_instance" "servidor" {
  name         = "vm-servidor"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size
    }
  }

  network_interface {
    network    = google_compute_network.vpc_principal.id
    subnetwork = google_compute_subnetwork.subred_privada.id
  }

  metadata = {
    ssh-keys       = "macale:${file(var.ssh_key_path)}"
    startup-script = file("${path.module}/startup-vm-servidor.sh")
  }

  tags = ["privada"]
}

#############################################
# MÁQUINA CLIENTE (privada)
#############################################

resource "google_compute_instance" "cliente" {
  name         = "vm-cliente"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size
    }
  }

  network_interface {
    network    = google_compute_network.vpc_principal.id
    subnetwork = google_compute_subnetwork.subred_privada.id
  }

  metadata = {
    ssh-keys       = "macale:${file(var.ssh_key_path)}"
    startup-script = templatefile("${path.module}/startup-vm-cliente.sh", {
      server_ip = google_compute_instance.servidor.network_interface[0].network_ip
    })
  }

  tags = ["privada"]
}
