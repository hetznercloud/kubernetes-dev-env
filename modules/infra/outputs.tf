output "name" {
  description = "Name of the environment"
  value       = var.name
}

output "ssh_private_key_filename" {
  description = "Path to the private SSH Key"
  value       = local_sensitive_file.ssh_private.filename
}

output "ssh_public_key_filename" {
  description = "Path to the public SSH Key"
  value       = local_sensitive_file.ssh_public.filename
}

output "control_server_ipv4" {
  description = "Public IPv4 of the control node"
  value       = hcloud_server.control.ipv4_address
}

output "kubeconfig_filename" {
  description = "Path to the Kubeconfig file, written by the k3sup provisioner"
  value       = local.kubeconfig_path
}

output "network_id" {
  description = "ID of the Hetzner Cloud Network the cluster runs in"
  value       = hcloud_network.cluster.id
}

output "cluster_cidr" {
  description = "CIDR range for the Pods"
  value       = var.cluster_cidr
}

output "use_cloud_routes" {
  description = "Whether the Hetzner Cloud network routes are used for Pod traffic"
  value       = var.use_cloud_routes
}

output "registry_service_ip" {
  description = "ClusterIP of the in-cluster Docker registry service"
  value       = module.registry_control.registry_service_ip
}

output "registry_port" {
  description = "Local port the in-cluster Docker registry is forwarded to"
  value       = module.registry_control.registry_port
}
