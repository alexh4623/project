output "admin_passwords" {
  description = "Admin passwords for all instances"
  value       = [for p in random_password.admin_password : p.result]
  sensitive   = true
}

output "instance_ips" {
  value = aws_instance.VM.*.public_ip
}

output "private_key_pem" {
  value = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
