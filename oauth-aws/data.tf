data "aws_ami" "debian-bullseye" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"] # Debian; https://wiki.debian.org/Cloud/AmazonEC2Image/Buster
}

data "aws_vpc" "main_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-vpc"]
  }
}

data "aws_subnet" "az1-public" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-az1-public"]
  }

  vpc_id = data.aws_vpc.main_vpc.id
}