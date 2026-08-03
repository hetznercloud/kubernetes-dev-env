output "registry_port_forward_filename" {
  description = "Path to the script forwarding the in-cluster Docker registry to localhost"
  value       = local_file.registry_port_forward.filename
}
