terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

resource "aws_instance" "publicInstance" {
  ami                         = module.vpc.ami
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.subnet_public
  vpc_security_group_ids      = ["${module.vpc.security_group}"]
  associate_public_ip_address = true
  tags = {
    Name = "public_insance"
  }
}
resource "aws_instance" "privateInstace" {
  ami                         = module.vpc.ami
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.subnet_private
  vpc_security_group_ids      = ["${module.vpc.security_group}"]
  associate_public_ip_address = false
  tags = {
    Name = "private_instance"
  }
}