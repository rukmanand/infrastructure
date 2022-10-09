
data "aws_subnets" "public" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["public-subnets"]
  }
}

resource "random_shuffle" "subnets" {
  input = data.aws_subnets.public.ids
  result_count = 1
}

resource "aws_instance" "instance" {
  count                       = "${var.ec2_count}"
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_value
  #availability_zone           = element(var.vpc_azs, count.index)
  subnet_id                   = "${element(data.aws_subnets.public.ids, 0)}"
  associate_public_ip_address = var.public_ip_status

  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]

  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }
  
  tags = {
    Name ="SERVER01"
    Environment = "platform"
    OS = "UBUNTU"
    Managed = "Terraform"
  }

  depends_on = [ aws_security_group.ec2-sg ]
}

resource "aws_lb_target_group_attachment" "lb-tg-jenkins" {
  count            = var.ec2_count
  target_group_arn = var.lb_tg_id
  target_id        = element(aws_instance.instance.*.id, count.index)
  port             = 8080
}

resource "aws_lb_target_group_attachment" "lb-tg-nexus" {
  count            = var.ec2_count
  target_group_arn = var.lb_tg_id_nexus
  target_id        = element(aws_instance.instance.*.id, count.index)
  port             = 8081
}

resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Jenkins"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Nexus"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Jenkins JNLP"
    from_port        = 50000
    to_port          = 50000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH to instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["157.48.221.84/32"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
    Environment = "platform"
  }
}