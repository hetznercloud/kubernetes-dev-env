# Environment
variable "name" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
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
variable "cluster_cidr" {
  description = "CIDR range for the Pods. Must be included in the range of the network (10.0.0.0/8) but must not overlap with the Subnet (10.0.0.0/24)."
  type        = string
  default     = "10.244.0.0/16"
}
variable "output_dir" {
  description = "Directory the generated files (SSH keys, kubeconfig, env.sh) are written to. Defaults to the `files` directory of the root module."
  type        = string
  default     = null
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
  default     = "cpx22"
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

# K3S
variable "k3s_channel" {
  description = "k3S channel used for the environment"
  type        = string
  default     = "stable"
}

variable "k3s_version" {
  description = "k3s version used for the environment"
  type        = string
  default     = null
}
