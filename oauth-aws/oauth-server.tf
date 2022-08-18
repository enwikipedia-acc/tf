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

  instance_initiated_shutdown_behavior = "terminate"

  tags = {
    "Name"      = "${var.project}-oauth"
    "publicdns" = "${var.linode_dns_name}.${var.linode_dns_zone}"
  }

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    tags = {
      "Name" = "${var.project}-oauth-root"
    }
  }

  user_data_replace_on_change = true
  user_data                   = <<EOF
#!/bin/bash -e
apt-get update
apt-get install -q -y git ansible jq
mkdir -p /opt/provisioning
git clone https://github.com/enwikipedia-acc/tf.git /opt/provisioning
cd /opt/provisioning/ansible

ln -s /opt/provisioning/ansible/provision-oauth.sh /usr/local/bin/acc-provision
chmod a+rx /opt/provisioning/ansible/provision-oauth.sh

acc-provision

EOF
}

resource "aws_ebs_volume" "oauth-www" {
  availability_zone = data.aws_subnet.az1-public.availability_zone
  size              = 3
  type              = "gp3"

  tags = {
    "Name" = "oauth-www"
  }
}

resource "aws_ebs_volume" "oauth-db" {
  availability_zone = data.aws_subnet.az1-public.availability_zone
  size              = 2
  type              = "gp3"

  tags = {
    "Name" = "oauth-db"
  }
}

resource "aws_volume_attachment" "oauth-www" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.oauth-www.id
  instance_id = aws_instance.oauth.id

  stop_instance_before_detaching = true
}

resource "aws_volume_attachment" "oauth-db" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.oauth-db.id
  instance_id = aws_instance.oauth.id

  stop_instance_before_detaching = true
}
