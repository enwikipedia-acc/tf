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

resource "aws_security_group" "web" {
  name        = "${var.project}-oauth-instance"
  description = "${var.project} OAuth instance SG"

  vpc_id = data.aws_vpc.main_vpc.id

  egress {
    description = "HTTP outbound for apt"
    # Required for apt

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    description = "HTTPS outbound for SSM and git"
    # Required for SSM

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }

  ingress {
    description = "HTTP inbound"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  ingress {
    description = "SSH inbound"

    cidr_blocks = ["0.0.0.0/0"]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
}

resource "aws_instance" "oauth" {
  ami                    = data.aws_ami.debian-bullseye.id
  instance_type          = var.oauth_instance_type_aws
  subnet_id              = data.aws_subnet.az1-public.id
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    "Name" = "${var.project}-oauth"
  }

  user_data_replace_on_change = true
  user_data                   = <<EOF
#!/bin/bash
apt-get update
apt-get install -q -y git ansible
mkdir -p /opt/provisioning
git clone https://github.com/stwalkerster/acc-ansible-test.git /opt/provisioning/ansible
cd /opt/provisioning/ansible
ls -l
EOF
}

output "dns" {
  value = "http://${aws_instance.oauth.public_dns}/"
  description = "MediaWiki OAuth test instance:"
}
