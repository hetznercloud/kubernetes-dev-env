# Cluster
variable "kubeconfig_path" {
  description = "Path to the Kubeconfig file of the cluster (see the `kubeconfig_filename` output of the infra module)"
  type        = string
}

variable "cluster_cidr" {
  description = "CIDR range for the Pods (see the `cluster_cidr` output of the infra module)"
  type        = string
  default     = "10.244.0.0/16"
}

variable "use_cloud_routes" {
  description = "Use the Hetzner Cloud network routes for Pod traffic. Enables hcloud-cloud-controller-manager routes controller and Cilium native routing. Must match the value used in the infra module."
  type        = bool
  default     = true
}

variable "output_dir" {
  description = "Directory the generated files (registry-port-forward.sh) are written to. Defaults to the `files` directory of the root module."
  type        = string
  default     = null
}

# Hetzner Cloud
variable "hcloud_token" {
  description = "Hetzner Cloud API token, deployed as a Secret for hcloud-cloud-controller-manager and the csi-driver"
  type        = string
  sensitive   = true
}

variable "hcloud_network_id" {
  description = "ID of the Hetzner Cloud Network the cluster runs in (see the `network_id` output of the infra module)"
  type        = string
}

# Deployments
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

# hcloud-cloud-controller-manager
variable "hccm_hcloud_endpoint" {
  description = "Sets the HCLOUD_ENDPOINT environment variable in the hcloud-cloud-controller-manager helm chart"
  type        = string
  default     = "https://api.hetzner.cloud/v1"
}

# Docker registry
variable "registry_service_ip" {
  description = "ClusterIP for the in-cluster Docker registry service. Must match the mirror configured on the nodes by the infra module (see its `registry_service_ip` output)."
  type        = string
  default     = "10.43.0.2"
}
