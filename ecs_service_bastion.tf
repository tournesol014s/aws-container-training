resource "aws_ecs_service" "sbcntrEcsBastionService" {
  name                               = "sbcntr-ecs-bastion-service"
  cluster                            = aws_ecs_cluster.sbcntrECSClusterFrontend.id
  task_definition                    = aws_ecs_task_definition.sbcntrBastionDef.arn
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  scheduling_strategy                = "REPLICA"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_controller {
    type = "ECS"
  }

  enable_ecs_managed_tags = true

  network_configuration {
    subnets = [
      aws_subnet.sbcntrSubnetPrivateContainer1a.id,
      aws_subnet.sbcntrSubnetPrivateContainer1c.id,
    ]
    security_groups = [
      aws_security_group.sbcntrSgFrontContainer.id,
    ]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

}

resource "aws_ecs_task_definition" "sbcntrBastionDef" {
  family                   = "bastion"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.sbcntrECSTaskRole.arn

  container_definitions = <<TASK_DEFINITION
[
    {
        "name": "bastion",
        "image": "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:bastion",
        "cpu": 256,
        "memory": 128,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.sbcntrBastionLog.name}",
                "awslogs-region": "${var.region}",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]
TASK_DEFINITION

}
