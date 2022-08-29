resource "aws_security_group" "base" {
  name        = "${var.project}-base"
  description = "${var.project} baseline SG"

  vpc_id = aws_vpc.main_vpc.id

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
    description = "SSH inbound"

    cidr_blocks = ["0.0.0.0/0"]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
}
