resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id # Replace with your VPC ID

  # Allow inbound HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}


# Create the Application Load Balancer
resource "aws_lb" "agent_apps" {
  name               = "agent-aapps"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "agent-aapps"
  }
}

# Create a target group
resource "aws_lb_target_group" "agent_apps" {
  name        = "agent-apps-tg"
  port        = 8501
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"  # Make sure this path exists in your application
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }

  deregistration_delay = 30

  tags = {
    Name = "agent-apps-tg"
  }
}


# Create a listener
resource "aws_lb_listener" "agent_apps" {
  load_balancer_arn = aws_lb.agent_apps.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.agent_apps.arn
  }
}

# Output the ALB DNS name
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.agent_apps.dns_name
}

# Output the target group ARN
output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.agent_apps.arn
}


resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-security-group"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id # Replace with your VPC ID

  # Allow inbound traffic from the ALB
  ingress {
    from_port       = 8501
    to_port         = 8501
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-tasks-security-group"
  }
}


# Allow traffic from ALB to ECS tasks
resource "aws_security_group_rule" "alb_to_ecs" {
  type                     = "egress"
  from_port                = 8501
  to_port                  = 8501
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

# Allow traffic from ALB to ECS tasks in the ECS tasks' security group