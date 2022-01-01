# Create the ECS Service and security groups
resource "aws_security_group" "ecs_sg" {
  name        = "Container and EFS ports"
  description = "Allow access to containers and EFS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Container port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "EFS access"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_service" "wordpress" {
  name            = "wordpress-service"
  cluster         = aws_ecs_cluster.wp_cluster.id
  task_definition = aws_ecs_task_definition.wp_task.arn
  desired_count   = 3

  launch_type      = "FARGATE"
  platform_version = "1.4.0"
# Enable execute command so we can connect to container to troubleshoot  
  enable_execute_command = true

  network_configuration {
    subnets = ["${module.vpc.private_subnets[0]}",
               "${module.vpc.private_subnets[1]}",
               "${module.vpc.private_subnets[2]}"
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
      target_group_arn = aws_lb_target_group.wp_alb_tg.arn
      container_name   = "wordpress"
      container_port   = 80
    }

}