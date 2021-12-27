# Application Load Balancer

# ALB security group
resource "aws_security_group" "alb_sg" {
  name        = "Allow HTTP,HTTPS"
  description = "Allow HTTP,HTTPS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

# Create the Application Load Balancer
resource "aws_lb" "wp_alb" {

  name               = "wordpress-alb"
  load_balancer_type = "application"
  internal           = false
  subnets = ["${module.vpc.public_subnets[0]}",
             "${module.vpc.public_subnets[1]}",
             "${module.vpc.public_subnets[2]}"
            ]
  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "wordpress-alb"
  }

}

# Create the Load Balancer Target Group and Health Checks.
# Register targets with one or more target groups. 
# The load balancer starts routing requests to a newly registered target as soon as the registration process completes.
# It can take a few minutes for the registration process to complete and health checks to start.
resource "aws_lb_target_group" "wp_alb_tg" {

  name        = "wp-alb-target-group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id


  health_check {
    port                = 80
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }

}

# Create listeners to check for connection requests, using the configured protocol and port .
# The rules defined for a listener determine how the load balancer routes requests to its registered targets.
resource "aws_lb_listener" "lb_listener" {

  load_balancer_arn = aws_lb.wp_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp_alb_tg.arn
  }
}

