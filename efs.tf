# Create the EFS security group
resource "aws_security_group" "wp_efs_sg" {
  name        = "EFS access within VPC"
  description = "EFS access within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "NFS access within VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create the EFS file system
resource "aws_efs_file_system" "efs_wp" {
  creation_token   = "efs-wp"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = false

  tags = {
    Name = "wp-storage"
  }
}

# Create the mount target in 3 different subnets
resource "aws_efs_mount_target" "wp_mnt_target" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.efs_wp.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.ecs_sg.id]

  depends_on = [aws_efs_file_system.efs_wp]
}