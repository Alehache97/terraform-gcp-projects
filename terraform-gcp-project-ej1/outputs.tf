output "vm_name" {
  description = "Nombre de la máquina virtual creada"
  value       = google_compute_instance.vm_simple.name
}

output "vm_internal_ip" {
  description = "Dirección IP interna de la VM"
  value       = google_compute_instance.vm_simple.network_interface[0].network_ip
}

output "vm_external_ip" {
  description = "Dirección IP pública de la VM"
  value       = google_compute_instance.vm_simple.network_interface[0].access_config[0].nat_ip
}
