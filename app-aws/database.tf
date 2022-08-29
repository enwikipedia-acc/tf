resource "aws_instance" "db" {
  ami                                  = data.aws_ami.debian-bullseye.id
  instance_type                        = var.db_instance_type_aws
  subnet_id                            = data.aws_subnet.az1-public.id
  iam_instance_profile                 = data.aws_iam_instance_profile.ssm.name
  key_name                             = var.key_pair_name
  associate_public_ip_address          = true
  monitoring                           = false
  instance_initiated_shutdown_behavior = "terminate"

  vpc_security_group_ids = [
    data.aws_security_group.base.id,
    aws_security_group.db.id,
    aws_security_group.db_target.id
  ]

  tags = {
    "Name" = "${var.project}-db"
  }

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    tags = {
      "Name" = "${var.project}-db-root"
    }
  }

  user_data_replace_on_change = true
  user_data                   = file("${path.module}/../userdata/app/db-userdata.sh")
}

resource "aws_ebs_volume" "app-db" {
  availability_zone = data.aws_subnet.az1-private.availability_zone
  size              = 5
  type              = "gp3"
  snapshot_id       = var.snapshot_db

  tags = {
    "Name" = "app-db"
  }
}

resource "aws_volume_attachment" "app-db" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.app-db.id
  instance_id = aws_instance.db.id

  stop_instance_before_detaching = true
}

resource "aws_ebs_volume" "app-dbbackup" {
  availability_zone = data.aws_subnet.az1-private.availability_zone
  size              = 5
  type              = "gp3"
  snapshot_id       = var.snapshot_dbbackup

  tags = {
    "Name" = "app-dbbackup"
  }
}

resource "aws_volume_attachment" "app-dbbackup" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.app-dbbackup.id
  instance_id = aws_instance.db.id

  stop_instance_before_detaching = true
}
