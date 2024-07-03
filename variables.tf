# Environment
variable "name" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
}

variable "worker_count" {
  description = "Number of worker for the environment"
  type        = number
  default     = 1
}

# Hetzner Cloud
variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}
variable "hcloud_server_type" {
  description = "Hetzner Cloud Server Type used for the environment"
  type        = string
  default     = "cpx21"
}
variable "hcloud_location" {
  description = "Hetzner Cloud Location used for the environment"
  type        = string
  default     = "fsn1"
}
variable "hcloud_image" {
  description = "Hetzner Cloud Image used for the environment"
  type        = string
  default     = "ubuntu-24.04"
}

# K3S
variable "k3s_channel" {
  description = "k3S channel used for the environment"
  type        = string
  default     = "stable"
}
