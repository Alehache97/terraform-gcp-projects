output "bastion_external_ip" {
  description = "IP pública del bastión"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "bastion_internal_ip" {
  description = "IP interna del bastión"
  value       = google_compute_instance.bastion.network_interface[0].network_ip
}

output "servidor_internal_ip" {
  description = "IP interna del servidor"
  value       = google_compute_instance.servidor.network_interface[0].network_ip
}

output "cliente_internal_ip" {
  description = "IP interna del cliente"
  value       = google_compute_instance.cliente.network_interface[0].network_ip
}
