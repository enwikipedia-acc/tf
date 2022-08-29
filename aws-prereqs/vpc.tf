resource "aws_vpc" "main_vpc" {
  tags = {
    "Name" = "${var.project}-vpc"
  }

  cidr_block           = "10.20.0.0/22"
  enable_dns_hostnames = true
}

resource "aws_subnet" "az1-public" {
  availability_zone       = "${var.aws_region}a"
  cidr_block              = "10.20.0.0/24"
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.project}-az1-public"
  }
}

resource "aws_subnet" "az2-public" {
  availability_zone       = "${var.aws_region}b"
  cidr_block              = "10.20.1.0/24"
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.project}-az2-public"
  }
}


resource "aws_subnet" "az1-private" {
  availability_zone = "${var.aws_region}a"
  cidr_block        = "10.20.2.0/24"
  vpc_id            = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.project}-az1-private"
  }
}

resource "aws_subnet" "az2-private" {
  availability_zone = "${var.aws_region}b"
  cidr_block        = "10.20.3.0/24"
  vpc_id            = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.project}-az2-private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.project}-igw"
  }
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project}-eigw"
  }
}

# resource "aws_eip" "az1-nat" {
#   vpc = true
#   depends_on                = [aws_internet_gateway.igw]
# }

# resource "aws_nat_gateway" "az1" {
#   allocation_id = aws_eip.az1-nat.id
#   subnet_id     = aws_subnet.az1-public.id

#   tags = {
#     Name = "${var.project}-az1-nat-gw"
#   }

#   depends_on = [aws_internet_gateway.igw]
# }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.project}-public"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private-az1" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.project}-private-az1"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_egress_only_internet_gateway.eigw.id
  }

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_nat_gateway.az1.id
  # }
}

resource "aws_route_table" "private-az2" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.project}-private-az2"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_egress_only_internet_gateway.eigw.id
  }

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_nat_gateway.az1.id
  # }
}

resource "aws_route_table_association" "az1-public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.az1-public.id
}

resource "aws_route_table_association" "az2-public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.az2-public.id
}

resource "aws_route_table_association" "az1-private" {
  route_table_id = aws_route_table.private-az1.id
  subnet_id      = aws_subnet.az1-private.id
}

resource "aws_route_table_association" "az2-private" {
  route_table_id = aws_route_table.private-az2.id
  subnet_id      = aws_subnet.az2-private.id
}
