# Security Group for K3s Node
resource "aws_security_group" "k3s_sg" {
  name        = "${var.project_name}-node-sg"
  description = "Security group for K3s spot instance node"
  vpc_id      = var.vpc_id


  # Allow HTTP traffic for the e-commerce web frontend
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP web traffic from anywhere"
  }

  # Allow HTTPS traffic for the e-commerce web frontend
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS web traffic from anywhere"
  }

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "Allow SSH access restricted to specific IP"
  }

  # Allow Kubernetes API access
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "Allow K3s API access restricted to specific IP"
  }

  # Allow all outbound traffic for the node to download packages, images, etc.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}