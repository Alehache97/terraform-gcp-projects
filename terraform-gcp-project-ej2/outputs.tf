output "vm_name" {
  description = "Nombre de la VM"
  value       = google_compute_instance.vm_red.name
}

output "vm_internal_ip" {
  description = "IP interna de la VM"
  value       = google_compute_instance.vm_red.network_interface[0].network_ip
}

output "vm_external_ip" {
  description = "IP pública de la VM"
  value       = google_compute_instance.vm_red.network_interface[0].access_config[0].nat_ip
}

output "network_name" {
  description = "Nombre de la red"
  value       = google_compute_network.red_personalizada.name
}

output "subnet_name" {
  description = "Nombre de la subred"
  value       = google_compute_subnetwork.subred_personalizada.name
}
