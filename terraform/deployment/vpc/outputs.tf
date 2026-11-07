# Outputs to be used by other modules

output "private_subnet_ids" {
  description = "A list of private subnet IDs"
  value       = values(aws_subnet.private)[*].id
}
