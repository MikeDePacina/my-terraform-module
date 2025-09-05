resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = var.num-of-private-subnets
  cidr_block        = cidrsubnet(var.vpc-cidr, 2, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  count             = var.num-of-public-subnets
  cidr_block        = cidrsubnet(var.vpc-cidr, 2, count.index + var.num-of-private-subnets)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_network_acl" "deny-internet-access" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port  = 0
    to_port    = 0
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    action     = "deny"
    rule_no    = 100
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    action     = "deny"
    rule_no    = 200
  }

  subnet_ids = aws_subnet.private[*].id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private_subnet_route_tables" {
  count = var.num-of-private-subnets
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_subnet_route_tables"{
  count = var.num-of-public-subnets
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = var.num-of-public-subnets
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_subnet_route_tables[count.index].id
}

resource "aws_route_table_association" "private_subnet_association"{
  count = var.num-of-private-subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_subnet_route_tables[count.index].id
}



