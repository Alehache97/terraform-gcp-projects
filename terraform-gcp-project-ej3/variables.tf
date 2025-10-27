variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
  default     = "proven-mystery-473711-n3"
}

variable "region" {
  description = "Región donde se desplegarán los recursos"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zona donde se desplegarán las instancias"
  type        = string
  default     = "europe-west1-b"
}

variable "machine_type" {
  description = "Tipo de máquina GCP"
  type        = string
  default     = "e2-micro"
}

variable "disk_size" {
  description = "Tamaño del disco en GB"
  type        = number
  default     = 10
}

variable "ssh_key_path" {
  description = "Ruta a la clave pública SSH"
  type        = string
  default     = "/home/macale/.ssh/id_rsa.pub"
}

variable "my_ip" {
  description = "IP o rango permitido para SSH al bastión"
  type        = string
  default     = "0.0.0.0/0" # solo para pruebas
}
