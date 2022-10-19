resource "aws_instance" "app" {
  ami                                  = data.aws_ami.debian-bullseye.id
  instance_type                        = var.app_instance_type_aws
  subnet_id                            = data.aws_subnet.az1-public.id
  iam_instance_profile                 = data.aws_iam_instance_profile.ssm.name
  key_name                             = var.key_pair_name
  associate_public_ip_address          = true
  monitoring                           = false
  instance_initiated_shutdown_behavior = "terminate"

  vpc_security_group_ids = [
    data.aws_security_group.base.id,
    aws_security_group.app.id,
    aws_security_group.app_target.id
  ]

  tags = {
    "Name"      = "${var.project}-app"
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
      "Name" = "${var.project}-app-root"
    }
  }

  user_data_replace_on_change = true
  user_data                   = file("${path.module}/../userdata/app/app-userdata.sh")
}

resource "aws_ebs_volume" "app-www" {
  availability_zone = data.aws_subnet.az1-public.availability_zone
  size              = 5
  type              = "gp3"
  snapshot_id       = var.snapshot_www

  tags = {
    "Name" = "app-www"
  }
}

resource "aws_volume_attachment" "app-www" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.app-www.id
  instance_id = aws_instance.app.id

  stop_instance_before_detaching = true
}

module "loadbalancer" {
  count  = var.use_lb ? 1 : 0
  source = "../modules/loadbalancer"

  name        = "acc-application"
  project     = var.project
  hostname    = local.hostname
  subnet_a_id = data.aws_subnet.az1-public.id
  subnet_b_id = data.aws_subnet.az2-public.id
  vpc_id      = data.aws_vpc.main_vpc.id
  instance_id = aws_instance.app.id

  target_sgs = [ aws_security_group.app_target.id ]
}
