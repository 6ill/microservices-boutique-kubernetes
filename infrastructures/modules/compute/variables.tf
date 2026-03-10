variable "project_name" {
  description = "Project name"
  type        = string
  default     = "k3s-ecommerce"
}

variable "vpc_id" {
  description = "VPC ID for instances"
  type        = string
}

variable "subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID  for K3s node"
  type        = string
}

variable "instance_type" {
  description = "EC2 type instance"
  type        = string
  default     = "t3.medium"
}