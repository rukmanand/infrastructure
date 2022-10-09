
locals {
  vpc_azs = { for azs, az in var.vpc_azs : azs => az }
  #subnets = { for sbs, sb in var.vpc_private_subnets: sb => sbs}
}

provider "aws" {
  region = var.vpc_region
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  tags = var.vpc_tags
}
  
resource "aws_subnet" "private-subnets" {
#   for_each = local.vpc_azs
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = element(var.vpc_private_subnets, each.value)
#   count = length(local.vpc_azs)
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = element(var.vpc_private_subnets, count.index)
  count                   = "${length(var.vpc_private_subnets)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(values(var.vpc_private_subnets), count.index)}"
  availability_zone       = "${element(keys(var.vpc_private_subnets), count.index)}"

  tags = {
    Name = "private-subnets"
  }
}

resource "aws_subnet" "public-subnets" {
#   availability_zones  = ["ap-south-1a", "ap-south-1b"]
#   for_each = local.vpc_azs
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = element(var.vpc_public_subnets, each.value)

#   count = length(local.vpc_azs)
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = element(var.vpc_public_subnets, count.index)

  count                   = "${length(var.vpc_public_subnets)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(values(var.vpc_public_subnets), count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(keys(var.vpc_public_subnets), count.index)}"

  tags = {
    Name = "public-subnets"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}   

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "rt-association" {
  # count = length(aws_subnet.public-subnets)
  # subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  # route_table_id = aws_route_table.public_rt.id

  for_each = local.vpc_azs
  subnet_id      = aws_subnet.public-subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_lb" "jenkins-alb" {
  name               = "terraform-alb-example"
  security_groups    = [aws_security_group.elb-sg.id]
  internal           = false
  load_balancer_type = "application"
  enable_cross_zone_load_balancing   = true
  subnets      = [for subnet in aws_subnet.public-subnets : subnet.id]
  #["element(var.vpc_public_subnets, count.index)"] #
  
  depends_on = [ aws_subnet.public-subnets, aws_security_group.elb-sg ]
}

resource "aws_lb_target_group" "jenkins-alb-tg" {
  name     = "alb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group" "nexus-alb-tg" {
  name     = "alb-tg-nexus"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_listener" "jenkins-lb-ls" {
  load_balancer_arn = aws_lb.jenkins-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-south-1:235410724307:certificate/3398e238-4079-4cbc-b294-0d86c1ea6099"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-alb-tg.arn
  }
}

resource "aws_lb_listener_rule" "jenkins-alb-ls-rule" {
  listener_arn = aws_lb_listener.jenkins-lb-ls.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-alb-tg.arn
  }

  condition {
    host_header {
      values = ["jenkins.rukmanand.com"]
    }
  }
}

resource "aws_security_group" "elb-sg" {
  vpc_id     = aws_vpc.vpc.id
  name = "terraform-example-elb"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}