# Get database credentials from AWS SSM Parameter Store
# name = "aws ssm parameter name"

# Database password
data "aws_ssm_parameter" "dbpassword" {
  name = "DBPassword"
}

# Database root password
data "aws_ssm_parameter" "dbrootpassword" {
  name = "DBRootPassword"
}
# Database user name
data "aws_ssm_parameter" "dbuser" {
  name = "DBUser"
}

# Database name
data "aws_ssm_parameter" "dbname" {
  name = "DBName"
}

# Create database security group
resource "aws_security_group" "db_sg" {
  name        = "Database access from within VPC"
  description = "Database access from within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Database access from within VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create Aurora cluster and cluster instances
resource "aws_db_subnet_group" "db_sb_group" {
   name       = "db-subnet-group"
   subnet_ids = ["${module.vpc.database_subnets[0]}",
                 "${module.vpc.database_subnets[1]}",
                 "${module.vpc.database_subnets[2]}"
                ]
}

resource "aws_rds_cluster" "wp_cluster" {
  cluster_identifier = "aurora-cluster-wordpress"
  availability_zones = module.vpc.azs
  database_name      = data.aws_ssm_parameter.dbname.value
  master_username    = data.aws_ssm_parameter.dbuser.value
  master_password    = data.aws_ssm_parameter.dbpassword.value

  engine             = var.db_engine
  engine_version     = var.db_engine_version

  db_subnet_group_name = aws_db_subnet_group.db_sb_group.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  port = "3306"

  skip_final_snapshot  = true
  apply_immediately    = true
  storage_encrypted    = false
  iam_database_authentication_enabled = false
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 3
  identifier         = "wp-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.wp_cluster.id
  instance_class     = var.db_instance_class
  engine             = var.db_engine
  engine_version     = var.db_engine_version

  publicly_accessible = false
  apply_immediately = true

  db_subnet_group_name = aws_db_subnet_group.db_sb_group.id

}