variable "vpc-cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "aws-region" {
  description = "The AWS region to deploy the resources"
  type        = string
}


variable "aws_access_key" {
  description = "The AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  type        = string
}

variable "num-of-private-subnets" {
  description = "The number of private subnets to create"
  type        = number
  default     = 1

  validation {
    condition     = var.num-of-private-subnets > 0 && var.num-of-private-subnets <= 2
    error_message = "The number of private subnets must be between 1 and 2."
  }
}

variable "num-of-public-subnets" {
  description = "The number of public subnets to create"
  type        = number
  default     = 1

  validation {
    condition     = var.num-of-public-subnets > 0 && var.num-of-public-subnets <= 2
    error_message = "The number of public subnets must be between 1 and 2."
  }
}


variable "ec2_instance_type" {
  description = "The EC2 instance type"
  type        = map(string)
  default = {
    default = "t3.micro"
    dev     = "t3.micro"
    prod    = "t3.small"
  }

}

