module "networking" {
  source                 = "../"
  num-of-private-subnets = 1
  num-of-public-subnets  = 1
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = "aws-access-key"
  secret_key = "aws-secret-key"
}