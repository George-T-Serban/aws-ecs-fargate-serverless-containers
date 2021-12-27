# Create VPC in 3 AZs
# Create 3 public subnets, 3 private subnets, 3 database subnets in 3 AZs
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = var.vpc_azs
  private_subnets  = var.private_subnet_cidr_blocks
  public_subnets   = var.public_subnet_cidr_blocks
  database_subnets = var.db_subnets

  enable_nat_gateway         = true
  single_nat_gateway         = false
  one_nat_gateway_per_az     = true
  create_igw                 = true
  manage_default_route_table = true
  enable_vpn_gateway         = false

}
