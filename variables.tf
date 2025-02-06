# Environment
variable "name" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
}

variable "deploy_hccm" {
  description = "Deploy hcloud-cloud-controller-manager through Helm"
  type        = bool
  default     = true
}
variable "deploy_csi_driver" {
  description = "Deploy the csi-driver through Helm"
  type        = bool
  default     = false
}
variable "use_cloud_routes" {
  description = "Use the Hetzner Cloud network routes for Pod traffic. Enables hcloud-cloud-controller-manager routes controller and Cilium native routing. Does not work with Robot servers."
  type        = bool
  default     = true
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
  default     = "hel1"
}
variable "hcloud_image" {
  description = "Hetzner Cloud Image used for the environment"
  type        = string
  default     = "ubuntu-24.04"
}
variable "hcloud_labels" {
  description = "Additional labels that are added to all Hetzner Cloud resources"
  type        = map(string)
  default     = {}
}

# hcloud-cloud-controller-manager
variable "hccm_hcloud_endpoint" {
  description = "Sets the HCLOUD_ENDPOINT environment variable in the hcloud-cloud-controller-manager helm chart"
  type        = string
  default     = "https://api.hetzner.cloud/v1"
}

# K3S
variable "k3s_channel" {
  description = "k3S channel used for the environment"
  type        = string
  default     = "stable"
}
