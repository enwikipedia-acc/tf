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

  egress {
    description = "SSH outbound for git"
    # Required for SSM

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    from_port = 22
    to_port   = 22
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

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project}-ssm"
  role = aws_iam_role.ssm.name
}

resource "aws_iam_role" "ssm" {
  name               = "${var.project}-ssm"
  assume_role_policy = data.aws_iam_policy_document.assumerole.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = data.aws_iam_policy.ssm_core.arn
}

resource "aws_iam_role_policy_attachment" "ssm_patch" {
  role       = aws_iam_role.ssm.name
  policy_arn = data.aws_iam_policy.ssm_patch.arn
}

resource "aws_instance" "oauth" {
  ami                                  = data.aws_ami.debian-bullseye.id
  instance_type                        = var.oauth_instance_type_aws
  subnet_id                            = data.aws_subnet.az1-public.id
  iam_instance_profile                 = aws_iam_instance_profile.ssm.name
  key_name                             = var.key_pair_name
  vpc_security_group_ids               = [aws_security_group.web.id]
  associate_public_ip_address          = true
  monitoring                           = false
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
  source = "./modules/loadbalancer"

  project     = var.project
  hostname    = local.hostname
  subnet_a_id = data.aws_subnet.az1-public.id
  subnet_b_id = data.aws_subnet.az2-public.id
  vpc_id      = data.aws_vpc.main_vpc.id
  instance_id = aws_instance.oauth.id
}

