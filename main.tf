provider "aws" {
  region = var.region
}

locals {

  tags = {

    Name = "Terraform"

  }
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = local.tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = local.tags

}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "public 1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Public 1b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Private 1a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Private 1b"
  }
}

# resource "aws_route_table" "rp" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   tags = local.tags
# }

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

   tags = {
    Name = "Terraform Public"
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Terraform Private"
  }
}


resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.rt_public.id
}


resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.rt_private.id
}


resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [0.0.0.0/0]
  }
  ngress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [0.0.0.0/0]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}