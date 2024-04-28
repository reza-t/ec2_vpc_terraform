provider "aws" {
  region = var.region
}

resource "aws_vpc" "mainVpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.serviceName}_mainVpc"
  }
}

resource "aws_subnet" "publicSubnet" {
  vpc_id            = aws_vpc.mainVpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az1
  tags = {
    Name = "${var.serviceName}_publicSubnet"
  }
}

resource "aws_subnet" "privateSubnet" {
  vpc_id            = aws_vpc.mainVpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az2
  tags = {
    Name = "${var.serviceName}_privateSubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainVpc.id
  tags = {
    Name = "${var.serviceName}_igw"
  }
}

resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.mainVpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.serviceName}_publicRouteTable"
  }
}

resource "aws_route_table_association" "publicAssosiation" {
  subnet_id      = aws_subnet.publicSubnet.id
  route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_eip" "mainEip" {
}

resource "aws_nat_gateway" "natGateway" {
  allocation_id = aws_eip.mainEip.id
  subnet_id     = aws_subnet.publicSubnet.id

  tags = {
    Name = "${var.serviceName}_natGateway"
  }
}

resource "aws_route_table" "privateRouteTable" {
  vpc_id = aws_vpc.mainVpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natGateway.id
  }

  tags = {
    Name = "${var.serviceName}_privateRouteTable"
  }
}

resource "aws_route_table_association" "privateAssisiation" {
  route_table_id = aws_route_table.privateRouteTable.id
  subnet_id      = aws_subnet.privateSubnet.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.mainVpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.serviceName}_allowAll"
  }
}

data "aws_ssm_parameter" "ssmParam" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}