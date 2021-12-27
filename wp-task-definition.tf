resource "aws_ecs_task_definition" "wp_task" {
    family = "wp_task"

    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]

    task_role_arn = "arn:aws:iam::648826012845:role/terraform-wordpress-demo-EC2"

    container_definitions = jsonencode([
    {
      name      = "wordpress_container"
      image     = "wordpress"
      cpu       = 1024
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 80
        }
      ]
    }
    ])

    volume {
      name = "wp-storage"

      efs_volume_configuration {
        file_system_id          = aws_efs_file_system.efs_wp.id
        root_directory          = "/var/www/html"
        transit_encryption      = "DISABLED"
        
      }
    }
}     