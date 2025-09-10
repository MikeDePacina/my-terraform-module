variable "max_num_of_private_instances" {
  description = "The maximum number of private instances to create"
  type        = number
  default     = 3

  validation {
    condition     = var.max_num_of_private_instances >= 1 && var.max_num_of_private_instances <= 5
    error_message = "The maximum number of private instances must be between 1 and 5."
  }
}

variable "max_num_of_public_instances" {
  description = "The maximum number of public instances to create"
  type        = number
  default     = 3

  validation {
    condition     = var.max_num_of_public_instances >= 1 && var.max_num_of_public_instances <= 5
    error_message = "The maximum number of public instances must be between 1 and 5."
  }
}


variable "min_num_of_private_instances" {
  description = "The minimum number of private instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.min_num_of_private_instances >= 1 && var.min_num_of_private_instances <= 5
    error_message = "The minimum number of private instances must be between 1 and 5."
  }
}

variable "min_num_of_public_instances" {
  description = "The minimum number of public instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.min_num_of_public_instances >= 1 && var.min_num_of_public_instances <= 5
    error_message = "The minimum number of public instances must be between 1 and 5."
  }
}


variable "private_sg_id" {
  description = "The security group ID for instances in a private subnet"
  type        = string
}

variable "public_sg_id" {
  description = "The security group ID for instances in a public subnet"
  type        = string
}


variable "private-subnet-ids" {
  type = list(string)
}

variable "public-subnet-ids" {
  type = list(string)
}