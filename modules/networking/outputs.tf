output "vpc_id" {
  value = aws_vpc.vpc.id
}
 
output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value = tomap({
    for v, subnets in aws_subnet.private-subnets : v => subnets.id
    })
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  #value       = aws_subnet.public-subnets[each.key]
  value = tomap({
    for k, subnets in aws_subnet.public-subnets : k => subnets.id
    })
}

output "alb-tg-id" {
  description = "LB target group"
  value = aws_lb_target_group.jenkins-alb-tg.arn
}

output "alb-tg-id-nexus" {
  description = "LB target group for nexus"
  value = aws_lb_target_group.nexus-alb-tg.arn
}