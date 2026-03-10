variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the security group will be created"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address to restrict access to sensitive ports (e.g., '203.0.113.1/32')"
  type        = string
  default     = "0.0.0.0/0" # Fallback to open
}