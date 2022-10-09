output "vpc_id" {
  value = module.platform-vpc.vpc_id
}

output "vpc_cidr" {
  value = module.platform-vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value = module.platform-vpc.private_subnet_ids
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value = module.platform-vpc.public_subnets_ids
}

output "alb-tg-id" {
  description = "LB target group"
  value = module.platform-vpc.alb-tg-id
}

output "alb-tg-id-nexus" {
  description = "LB target group"
  value = module.platform-vpc.alb-tg-id-nexus
}