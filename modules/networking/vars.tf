
variable "vpc_region" {
  description = "Region of VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_az" {
  description = "Availability zone for VPC"
  type        = string
  default = "ap-south-1a"
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = map
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = map
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default     = {
    Project   = "terraform-example"
    Environment = "platform-tools"
  }
}