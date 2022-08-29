terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

variable "project" {
  type = string
}

variable "name" {
  type = string
}

variable "subnet_a_id" {
  type = string
}
variable "subnet_b_id" {
  type = string
}
variable "hostname" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "instance_id" {
  type = string
}
variable "healthcheck_path" {
  type    = string
  default = "/"
}

variable "target_sgs" {
  type = list(string)
  default = []
}

output "lb_hostname" {
  value = aws_alb.web.dns_name
}

resource "aws_security_group" "web" {
  name        = "lb-${var.name}"
  description = "${var.project} Load Balancer"

  vpc_id = var.vpc_id

  egress {
    description = "HTTP outbound"

    security_groups = var.target_sgs

    from_port = 80
    to_port   = 80
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
    description = "HTTPS inbound"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }
}

resource "aws_alb" "web" {
  name = "${var.name}-lb"

  enable_http2 = true

  security_groups = [aws_security_group.web.id]

  subnet_mapping {
    subnet_id = var.subnet_a_id
  }
  subnet_mapping {
    subnet_id = var.subnet_b_id
  }
}

resource "aws_alb_listener" "web80" {
  port     = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  load_balancer_arn = aws_alb.web.id
}

resource "aws_alb_listener" "web443" {
  port     = 443
  protocol = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web80.id
  }

  load_balancer_arn = aws_alb.web.id
  certificate_arn   = data.aws_acm_certificate.web.arn
}

data "aws_acm_certificate" "web" {
  domain   = var.hostname
  statuses = ["ISSUED"]
}

resource "aws_alb_target_group" "web80" {
  port     = 80
  protocol = "HTTP"
  name     = "lb-${var.name}-tg80"

  health_check {
    interval          = 5
    healthy_threshold = 2
    timeout           = 2
    path              = var.healthcheck_path
  }

  vpc_id = var.vpc_id
}

resource "aws_lb_target_group_attachment" "application" {
  target_group_arn = aws_alb_target_group.web80.arn
  target_id        = var.instance_id
  port             = 80
}

