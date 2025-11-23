# ----------------------------
# DISCO ADICIONAL VACÍO
# ----------------------------
resource "google_compute_disk" "disco2" {
  name  = "disco2-vm-red"
  type  = "pd-standard"
  zone  = var.zone
  size  = 10
}

# ----------------------------
# MÁQUINA VIRTUAL SIMPLE
# ----------------------------

resource "google_compute_instance" "vm_simple" {
  name         = "vm-ejemplo1"
  machine_type = var.machine_type

  # Disco principal
  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.disk_size
    }
  }

  # Disco adicional
  attached_disk {
    source = google_compute_disk.disco2.id
  }

  # Interfaz de red: red por defecto con IP pública
  network_interface {
    network = "default"
    access_config {}
  }

  # Inyectar clave SSH para el usuario por defecto
  metadata = {
    ssh-keys = "macale:${file(var.ssh_key_path)}"
  }

  tags = ["terraform", "vm-ejemplo1"]
}
