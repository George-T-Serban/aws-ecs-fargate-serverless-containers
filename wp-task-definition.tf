resource "aws_ecs_task_definition" "wp_task" {

  depends_on = [aws_rds_cluster.wp_cluster, aws_efs_file_system.efs_wp, aws_efs_mount_target.wp_mnt_target, aws_security_group.ecs_sg]

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
      "environment" : [
          { "name" : "WORDPRESS_DB_HOST" , "value" : "${aws_rds_cluster.wp_cluster.endpoint}" }, 
          { "name" : "WORDPRESS_DB_USER" , "value" : "${data.aws_ssm_parameter.dbuser.value}" }, 
          { "name" : "WORDPRESS_DB_PASSWORD" , "value" : "${data.aws_ssm_parameter.dbpassword.value}" }, 
          { "name" : "WORDPRESS_DB_NAME" , "value" : "${data.aws_ssm_parameter.dbname.value}" }      
            
      ]   

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