output "ssh_private_key_filename" {
  description = "Path to the private SSH Key"
  value       = local_sensitive_file.ssh_private.filename
}

output "ssh_public_key_filename" {
  description = "Path to the public SSH Key"
  value       = local_sensitive_file.ssh_public.filename
}
