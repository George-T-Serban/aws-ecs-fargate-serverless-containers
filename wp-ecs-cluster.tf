resource "aws_ecs_cluster" "wp_cluster" {
  name = "wordpress-ecs-cluster"

  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}