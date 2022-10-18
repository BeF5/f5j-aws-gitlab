provider "aws" {
  #profile = var.aws_profile
  region  = var.aws_region
}

#----- Create VPC -----

resource "aws_vpc" "lab_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lab_vpc"
    Lab  = "Containers"
  }
}

# Internet gateway

resource "aws_internet_gateway" "lab_internet_gateway" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab_igw"
    Lab  = "Containers"
  }
}

# Route tables

resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_internet_gateway.id
  }

  tags = {
    Name = "lab_public"
    Lab  = "Containers"
  }
}

resource "aws_default_route_table" "lab_private_rt" {
  default_route_table_id = aws_vpc.lab_vpc.default_route_table_id

  tags = {
    Name = "lab_private"
    Lab  = "Containers"
  }
}

# Subnets

resource "aws_subnet" "external1_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["external1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "lab_external1"
    Lab  = "Containers"
  }
}

resource "aws_route_table_association" "lab_external1_assoc" {
  subnet_id      = aws_subnet.external1_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}


#----- Set default SSH key pair -----
resource "aws_key_pair" "lab_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

#----- Deploy Ctfd -----
module "ec2-gitlab" {
  source        = "./ec2-gitlab"
  aws_region    = var.aws_region
  aws_profile   = var.aws_profile
  myIP          = "${chomp(data.http.myIP.body)}/32"
  #myIP          = "0.0.0.0/0"
  key_name      = var.key_name
  instance_type = var.ec2-gitlab_instance_type
  ec2-gitlab_count    = var.ec2-gitlab_count
  vpc_id        = aws_vpc.lab_vpc.id
  vpc_cidr      = var.vpc_cidr
  vpc_subnet    = [aws_subnet.external1_subnet.id]
}

