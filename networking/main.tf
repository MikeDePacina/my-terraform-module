resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
}

locals {
  subnets_cidr         = cidrsubnets(var.vpc-cidr, var.num-of-private-subnets + var.num-of-public-subnets)
  private_subnets_cidr = slice(local.subnets_cidr, 0, var.num-of-private-subnets)
  public_subnets_cidr  = slice(local.subnets_cidr, var.num-of-private-subnets, length(local.subnets_cidr))
}


resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = var.num-of-private-subnets
  cidr_block        = local.private_subnets_cidr[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  count             = var.num-of-public-subnets
  cidr_block        = local.public_subnets_cidr[count.index]
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

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "route" {
  count                  = var.num-of-public-subnets
  route_table_id         = aws_route_table.route-table.id
  destination_cidr_block = local.public_subnets_cidr[count.index]
  gateway_id             = aws_internet_gateway.gateway.id
}
