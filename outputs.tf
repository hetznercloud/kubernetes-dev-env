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
  description = "Path to the Kubeconfig file"
  value       = data.local_sensitive_file.kubeconfig.filename
}
