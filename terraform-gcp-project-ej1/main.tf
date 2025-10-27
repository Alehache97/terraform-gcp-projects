# ----------------------------
# MÁQUINA VIRTUAL SIMPLE
# ----------------------------

resource "google_compute_instance" "vm_simple" {
  name         = "vm-ejemplo1"
  machine_type = var.machine_type

  # Disco principal
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size
    }
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
