output "instances" {
  description = "Worker instances"
  value       = aws_instance.worker
}

output "instance_ids" {
  description = "Worker instance IDs"
  value       = aws_instance.worker[*].id
}

output "private_ips" {
  description = "Worker private IP addresses"
  value       = aws_instance.worker[*].private_ip
}

output "public_ips" {
  description = "Worker public IP addresses"
  value       = aws_instance.worker[*].public_ip
}

output "instance_names" {
  description = "Worker instance names"
  value       = aws_instance.worker[*].tags.Name
}
