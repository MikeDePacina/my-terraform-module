variable "vpc-cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
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


variable "allowed-traffic-from-and-to-public-to-private-subnets" {
  type = list(object({
    from_port = number,
    to_port   = number,
    protocol  = string,
  }))
  default     = []
  description = "List of allowed traffic from and to private and public to create NACL rules and SGs"
}
