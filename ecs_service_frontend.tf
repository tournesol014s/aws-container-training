resource "aws_ecs_service" "sbcntrEcsFrontendService" {
  name                               = "sbcntr-ecs-frontend-service"
  cluster                            = aws_ecs_cluster.sbcntrECSClusterFrontend.id
  task_definition                    = aws_ecs_task_definition.sbcntrFrontendDef.arn
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

  health_check_grace_period_seconds = 120

  load_balancer {
    target_group_arn = aws_lb_target_group.sbcntrTargetGroupFrontend.arn
    container_name   = "app"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

}

resource "aws_ecs_task_definition" "sbcntrFrontendDef" {
  family                   = "sbcntr-frontend-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<TASK_DEFINITION
[
    {
        "name": "app",
        "image": "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:dbv1",
        "cpu": 256,
        "memory": 512,
        "portMappings": [
            {
                "containerPort": 80
            }
        ],
        "essential": true,
        "environment": [
            {"name": "SESSION_SECRET_KEY", "value": "41b678c65b37bf99c37bcab522802760"},
            {"name": "APP_SERVICE_HOST", "value": "http://${aws_lb.sbcntrAlbInternal.dns_name}"},
            {"name": "NOTIF_SERVICE_HOST", "value": "http://${aws_lb.sbcntrAlbInternal.dns_name}"}
        ],
        "secrets": [
            {"name": "DB_HOST", "valueFrom": "${aws_secretsmanager_secret.sbcntrMySqlSecret.arn}:host::"},
            {"name": "DB_NAME", "valueFrom": "${aws_secretsmanager_secret.sbcntrMySqlSecret.arn}:dbname::"},
            {"name": "DB_USERNAME", "valueFrom": "${aws_secretsmanager_secret.sbcntrMySqlSecret.arn}:username::"},
            {"name": "DB_PASSWORD", "valueFrom": "${aws_secretsmanager_secret.sbcntrMySqlSecret.arn}:password::"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.sbcntrFrontendLog.name}",
                "awslogs-region": "${var.region}",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]
TASK_DEFINITION

}
