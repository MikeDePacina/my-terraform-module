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
  value = aws_subnet.private[*].cidr_block
}

output "public_subnets_cidr" {
  value = aws_subnet.public[*].cidr_block
}


