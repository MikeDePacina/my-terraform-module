data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


# data "aws_subnets" "private_subnets" {
#   filter {
#     name   = "tag:Name"
#     values = ["private-subnet-*"]
#   }
# }

# data "aws_subnets" "public_subnets" {
#   filter {
#     name   = "tag:Name"
#     values = ["public-subnet-*"]
#   }
# }