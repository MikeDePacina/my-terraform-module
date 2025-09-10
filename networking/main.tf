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

locals {
  private_subnets_cidr_blocks = aws_subnet.private[*].cidr_block
  public_subnets_cidr_blocks  = aws_subnet.public[*].cidr_block

  allowed_traffic_with_private_subnets_cidr = flatten([
    for rule in var.allowed-traffic-from-and-to-public-to-private-subnets : [
      for cidr in local.private_subnets_cidr_blocks : {
        from_port  = rule.from_port
        to_port    = rule.to_port
        action     = "allow"
        protocol   = rule.protocol
        cidr_block = cidr # Add the cidr_block attribute here
      }
    ]
  ])

  allowed_traffic_with_public_subnets_cidr = flatten([
    for rule in var.allowed-traffic-from-and-to-public-to-private-subnets : [
      for cidr in local.public_subnets_cidr_blocks : {
        from_port  = rule.from_port
        to_port    = rule.to_port
        action     = "allow"
        protocol   = rule.protocol
        cidr_block = cidr # Add the cidr_block attribute here
      }
    ]
  ])
  
  }


resource "aws_network_acl" "private_subnets_nacl" {
  vpc_id = aws_vpc.main.id

  #allow specified inbound traffic from instances in public subnet to instances in private subnet
  dynamic "ingress" {
    for_each = length(var.allowed-traffic-from-and-to-public-to-private-subnets) > 0 ? local.allowed_traffic_with_public_subnets_cidr : []
    content {
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      protocol   = ingress.value.protocol
      cidr_block = ingress.value.cidr_block
      action     = "allow"
      rule_no    = (100 + ingress.key)
    }
  }

  #also need to allow return traffic from the specified allowed inbound traffic
  dynamic "egress" {
    for_each = length(var.allowed-traffic-from-and-to-public-to-private-subnets) > 0 ? local.allowed_traffic_with_public_subnets_cidr : []
    content {
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
      protocol   = egress.value.protocol
      cidr_block = egress.value.cidr_block
      action     = "allow"
      rule_no    = (200 + egress.key)
    }
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    action     = "deny"
    rule_no    = 300
  }

  subnet_ids = aws_subnet.private[*].id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private_subnet_route_tables" {
  count  = var.num-of-private-subnets
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_subnet_route_tables" {
  count  = var.num-of-public-subnets
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

resource "aws_route_table_association" "private_subnet_association" {
  count          = var.num-of-private-subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_subnet_route_tables[count.index].id
}

resource "aws_security_group" "public-instances-sg" {
  name        = "allow-ssh-http-https"
  description = "Only allow SSH, HTTP, and HTTPS traffic from internet to public instances and specified ports from private instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = length(var.allowed-traffic-from-and-to-public-to-private-subnets) > 0 ? var.allowed-traffic-from-and-to-public-to-private-subnets : []
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = aws_subnet.private[*].cidr_block
    }
  }

  #allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-instances-sg" {
  name        = "private instances sg"
  description = "To allow traffic from specified ports from public instances to private instances"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = length(var.allowed-traffic-from-and-to-public-to-private-subnets) > 0 ? var.allowed-traffic-from-and-to-public-to-private-subnets : []
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = aws_subnet.public[*].cidr_block
    }
  }


  dynamic "egress" {
    for_each = length(var.allowed-traffic-from-and-to-public-to-private-subnets) > 0 ? var.allowed-traffic-from-and-to-public-to-private-subnets : []
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = aws_subnet.public[*].cidr_block
    }
  }
}