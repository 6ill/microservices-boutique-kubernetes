# output "public_ip" {
#   description = "The public IP address of EC2 that run K3s"
#   value = 
# }

output "vpc_id" {
  description = "The ID of the main VPC"
  value       = module.networking.vpc_id
}

output "security_group_id" {
  description = "The ID of the K3s Node Security Group"
  value       = module.security.security_group_id
}

output "next_steps" {
  description = "Instructions for accessing the cluster"
  value       = "Infrastructure deployed! Wait 2-3 minutes for the Spot Instance to boot and install K3s. You can access the node via AWS SSM Console."
}