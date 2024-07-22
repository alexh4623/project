output "admin_passwords" {
  description = "Admin passwords for all instances"
  value       = [for p in random_password.admin_password : p.result]
  sensitive   = true
}

output "instance_ips" {
  value = aws_instance.VM.*.private_ip
}

/*output "ping_results" {
  value = "Ping results will be in /tmp/ping_results.log on each instance."
}*/