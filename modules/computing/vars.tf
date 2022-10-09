# variable "elb_port" {
#   description = "The port the server will use for HTTP requests"
#   type        = number
# }

# variable "server_port" {
#   description = "The port the server will use for HTTP requests"
#   type        = number
# }

variable "ec2_count" {
  description = "No.of ec2 instances"
  type        = number
}

# variable "network_interface_id" {
#   type = string
#   default = "network_id_from_aws"
# }

variable "ami_id" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list
}

# variable "subnet_id" {
#   description = "Subnets for VPC"
#   type        = list
# }

# variable "public_subnets" {
#   description = "Subnets for VPC"
#   type        = string
# }

variable "key_pair_value" {
    type = string
}

variable "public_ip_status" {
  description = "Assigning public IP for Instance"
  type = bool
}

variable "lb_tg_id" {
  description = "Target Group Id for association"
  type = string
}

variable "lb_tg_id_nexus" {
  description = "Target Group Id for association"
  type = string
}

variable "vpc_id" {
  description = "vpc id"
  type = string  
}
