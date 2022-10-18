variable "aws_profile" {
}

variable "aws_region" {
}

variable "vpc_cidr" {
}

data "aws_availability_zones" "available" {
}

variable "env_count" {
}

variable "cidrs" {
  type = map(string)
}

data "http" "myIP" {
  url = "http://ipv4.icanhazip.com"
}

variable "key_name" {
}

variable "public_key_path" {
}

variable "ec2-gitlab_instance_type" {
}

variable "ec2-gitlab_count" {
}



