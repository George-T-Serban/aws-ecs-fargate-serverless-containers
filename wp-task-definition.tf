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

resource "aws_ecs_task_definition" "wp_task" {
  depends_on = [aws_efs_file_system.efs_wp, aws_efs_mount_target.wp_mnt_target, aws_security_group.ecs_sg]

  family                   = "wordpress"
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = "arn:aws:iam::648826012845:role/terraform-wordpress-fargate"
  task_role_arn      = "arn:aws:iam::648826012845:role/terraform-wordpress-fargate"

  container_definitions = jsonencode([
    {
      "name" : "wordpress",
      "image" : "wordpress"

      "cpu"       = 1024,
      "memory"    = 2048,
      "essential" = true,

      "mountPoints" : [
        {
          "containerPath" : "/var/www/html",
          "sourceVolume" : "efs-wp"
        }
      ],

      "portMappings" : [
        {
          "hostPort" : 80,
          "containerPort" : 80,
          "protocol" : "tcp"
        }
      ],

    }

  ])

  volume {
    name = "efs-wp"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.efs_wp.id
      transit_encryption = "DISABLED"
    }
  }


}