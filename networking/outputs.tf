output "vpc-id" {
  value = aws_vpc.main.id
}

output "private-subnet-ids" {
  value = aws_subnet.private[*].id
}

output "public-subnet-ids" {
  value = aws_subnet.public[*].id
}

output "private_subnets_cidr" {
  value = local.private_subnets_cidr
}

output "public_subnets_cidr" {
  value = local.public_subnets_cidr
}


