module "platform-vpc" {
  source              = "../modules/networking"
  vpc_region          = "ap-south-1"
  vpc_name            = "tools-vpc"
  vpc_cidr            = "10.20.0.0/16"
  vpc_az              = "ap-south-1a"
  vpc_azs             = ["ap-south-1a", "ap-south-1b"]

  vpc_private_subnets  = {
    ap-south-1a = "10.20.8.0/24"
    ap-south-1b = "10.20.16.0/24"
  }
  vpc_public_subnets  = {
    ap-south-1a = "10.20.56.0/24"
    ap-south-1b = "10.20.64.0/24"
  }
}

module "compute" {
  source              = "../modules/computing"
  vpc_azs             = ["ap-south-1a", "ap-south-1b"]
  vpc_id              = module.platform-vpc.vpc_id
  ec2_count           = 1
  ami_id              = "ami-094466b68260d9a33"
  instance_type       = "t2.large"
  public_ip_status    = true
  key_pair_value      = "jenkins"
  lb_tg_id            = module.platform-vpc.alb-tg-id
  lb_tg_id_nexus      = module.platform-vpc.alb-tg-id-nexus
}