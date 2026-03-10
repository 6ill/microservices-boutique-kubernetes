variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for Public Subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone code for subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for K3s node"
  type        = string
}

variable "my_ip" {
  description = "Your personal public IP address to allow SSH and K3s API access (Format: 'X.X.X.X/32')"
  type        = string
}