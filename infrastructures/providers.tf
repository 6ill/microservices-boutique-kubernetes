terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "state-boutique-cmqmnc"
    key    = "cluster/terraform.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Environment = "portfolio"
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  }
}