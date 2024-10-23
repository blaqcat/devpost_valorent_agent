resource "aws_ecs_service" "valorant_agent" {
  name            = "valorant_agent"
  cluster         = "valorant_cluster"
  task_definition = data.aws_ecs_task_definition.chat_agent.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-03f6ae75b7be8cea2", "subnet-047b2d3a786588de6"]
    security_groups  = [aws_security_group.ecs_tasks.id] # Replace with your security group ID
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.agent_apps.arn # Assuming you're using the target group from the previous example
    container_name   = "valorant_agent"
    container_port   = 8501
  }

  tags = merge(
    var.hackathon_tag,
    {
      create_by = "Terraform"
    }
  )
}

# If you haven't defined the ECS cluster in Terraform yet, you can do so like this:
resource "aws_ecs_cluster" "valorant_cluster" {
  name = "valorant_cluster"

  tags = merge(
    var.hackathon_tag,
    {
      create_by = "Terraform"
    }
  )
}



data "aws_ecs_task_definition" "chat_agent" {
  task_definition = "chat-agents"
}

# Output the service name
output "ecs_service_name" {
  value = aws_ecs_service.valorant_agent.name
}
