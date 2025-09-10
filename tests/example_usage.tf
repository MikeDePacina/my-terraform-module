terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = "access_key"
  secret_key = "secret_key"
}

module "networking" {
  source                 = "../networking"
  num-of-private-subnets = 1
  num-of-public-subnets  = 1
  allowed-traffic-from-and-to-public-to-private-subnets = [{
    from_port = 22,
    to_port   = 22,
    protocol  = "tcp",
    }, {
    from_port = 8080,
    to_port   = 8080,
    protocol  = "tcp",
    }, {
    from_port = 3306,
    to_port   = 3306,
    protocol  = "tcp",
  }]
}

module "compute" {
  source                       = "../compute"
  private_sg_id                = module.networking.private_sg_id
  public_sg_id                 = module.networking.public_sg_id
  private-subnet-ids           = module.networking.private-subnet-ids
  public-subnet-ids            = module.networking.public-subnet-ids
  min_num_of_private_instances = 1
  max_num_of_private_instances = 3
  min_num_of_public_instances  = 1
  max_num_of_public_instances  = 3
}