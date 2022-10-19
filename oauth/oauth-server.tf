resource "aws_security_group" "web" {
  name        = "${var.project}-oauth-app"
  description = "${var.project} OAuth instance SG"

  vpc_id = data.aws_vpc.main_vpc.id

  ingress {
    description = "HTTP inbound"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }
}

resource "aws_security_group" "web_target" {
  name        = "${var.project}-oauth-target"
  description = "${var.project} OAuth instance SG"

  vpc_id = data.aws_vpc.main_vpc.id
}

resource "aws_instance" "oauth" {
  ami                                  = data.aws_ami.debian-bullseye.id
  instance_type                        = var.oauth_instance_type_aws
  subnet_id                            = data.aws_subnet.az1-public.id
  iam_instance_profile                 = data.aws_iam_instance_profile.ssm.name
  key_name                             = var.key_pair_name
  associate_public_ip_address          = true
  monitoring                           = false
  instance_initiated_shutdown_behavior = "terminate"


  vpc_security_group_ids = [
    data.aws_security_group.base.id,
    aws_security_group.web.id,
    aws_security_group.web_target.id
  ]

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
  user_data                   = file("${path.module}/../userdata/oauth/userdata.sh")
}

resource "aws_ebs_volume" "oauth-www" {
  availability_zone = data.aws_subnet.az1-public.availability_zone
  size              = 3
  type              = "gp3"
  snapshot_id       = var.snapshot_www

  tags = {
    "Name" = "oauth-www"
  }
}

resource "aws_ebs_volume" "oauth-db" {
  availability_zone = data.aws_subnet.az1-public.availability_zone
  size              = 2
  type              = "gp3"
  snapshot_id       = var.snapshot_db

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

module "loadbalancer" {
  count  = var.use_lb ? 1 : 0
  source = "../modules/loadbalancer"

  name        = "acc-oauth"
  project     = var.project
  hostname    = local.hostname
  subnet_a_id = data.aws_subnet.az1-public.id
  subnet_b_id = data.aws_subnet.az2-public.id
  vpc_id      = data.aws_vpc.main_vpc.id
  instance_id = aws_instance.oauth.id

  healthcheck_path = "/w/index.php/Main_Page"

  target_sgs = [ aws_security_group.web_target.id ]
}

