variable "project_id" {
  type    = string
  default = "proven-mystery-473711-n3"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-b"
}

variable "cluster_name" {
  type    = string
  default = "gke-cluster"
}

variable "node_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "node_min" {
  type    = number
  default = 0
}

variable "node_max" {
  type    = number
  default = 20
}

variable "domain" {
  type    = string
  default = "alejandrohj.es"
}

variable "email" {
  type    = string
  default = "alejandroherrera140697@gmail.com"
}
