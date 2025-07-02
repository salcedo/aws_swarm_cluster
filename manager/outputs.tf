output "instances" {
  description = "Manager instances"
  value       = aws_instance.manager
}

output "instance_ids" {
  description = "Manager instance IDs"
  value       = aws_instance.manager[*].id
}

output "private_ips" {
  description = "Manager private IP addresses"
  value       = aws_instance.manager[*].private_ip
}

output "public_ips" {
  description = "Manager public IP addresses"
  value       = aws_instance.manager[*].public_ip
}

output "instance_names" {
  description = "Manager instance names"
  value       = aws_instance.manager[*].tags.Name
}

output "placement_group_id" {
  description = "Manager placement group ID"
  value       = aws_placement_group.manager.id
}

output "placement_group_name" {
  description = "Manager placement group name"
  value       = aws_placement_group.manager.name
}
