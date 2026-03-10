output "security_group_id" {
  description = "The ID of the created Security Group to be attached to the EC2 instances"
  value       = aws_security_group.k3s_sg.id
}