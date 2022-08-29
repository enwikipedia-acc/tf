resource "aws_security_group" "app" {
  name        = "${var.project}-app"
  description = "${var.project} app SG"

  vpc_id = data.aws_vpc.main_vpc.id


  ingress {
    description = "HTTP inbound"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    description = "MySQL outbound"

    security_groups = [
        aws_security_group.db_target.id
    ]

    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
  }

  egress {
    description = "AMQPS outbound"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    from_port = 5671
    to_port   = 5671
    protocol  = "tcp"
  }
}

resource "aws_security_group" "app_target" {
  name        = "${var.project}-app-target"
  description = "${var.project} app SG"

  vpc_id = data.aws_vpc.main_vpc.id
}


resource "aws_security_group" "db" {
  name        = "${var.project}-db"
  description = "${var.project} db SG"

  vpc_id = data.aws_vpc.main_vpc.id


  ingress {
    description = "MySQL inbound"

    security_groups = [
        aws_security_group.app_target.id
    ]

    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
  }
}

resource "aws_security_group" "db_target" {
  name        = "${var.project}-db-target"
  description = "${var.project} db SG"

  vpc_id = data.aws_vpc.main_vpc.id

}
