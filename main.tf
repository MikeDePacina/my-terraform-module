terraform {
  required_version = "1.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }
}

provider "aws" {
  region     = var.aws-region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "networking" {
  source                 = "./networking"
  vpc-cidr               = var.vpc-cidr
  num-of-private-subnets = var.num-of-private-subnets
  num-of-public-subnets  = var.num-of-public-subnets
}