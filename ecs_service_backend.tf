resource "aws_ecs_service" "sbcntrEcsBackendService" {
  name                               = "sbcntr-ecs-backend-service"
  cluster                            = aws_ecs_cluster.sbcntrEcsBackendCluster.id
  task_definition                    = aws_ecs_task_definition.sbcntrBackendDef.arn
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  scheduling_strategy                = "REPLICA"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  enable_ecs_managed_tags = true

  network_configuration {
    subnets = [
      aws_subnet.sbcntrSubnetPrivateContainer1a.id,
      aws_subnet.sbcntrSubnetPrivateContainer1c.id,
    ]
    security_groups = [
      aws_security_group.sbcntrSgContainer.id,
    ]
    assign_public_ip = false
  }

  health_check_grace_period_seconds = 120

  load_balancer {
    target_group_arn = aws_lb_target_group.sbcntrTgSbcntrdemoBlue.arn
    container_name   = "app"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      desired_count,
      task_definition,
    ]
  }

}

resource "aws_appautoscaling_target" "sbcntrECSBackendAutoScalingTarget" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.sbcntrEcsBackendCluster.name}/${aws_ecs_service.sbcntrEcsBackendService.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [
      min_capacity
    ]
  }
}

resource "aws_appautoscaling_policy" "sbcntrECSBackendAutoScalingPolicy" {
  name               = "sbcntr-ecs-ScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.sbcntrECSBackendAutoScalingTarget.service_namespace
  resource_id        = aws_appautoscaling_target.sbcntrECSBackendAutoScalingTarget.resource_id
  scalable_dimension = aws_appautoscaling_target.sbcntrECSBackendAutoScalingTarget.scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 80
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }

}

resource "aws_ecs_task_definition" "sbcntrBackendDef" {
  family                   = "sbcntr-backend-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.sbcntrECSTaskRole.arn

  container_definitions = <<TASK_DEFINITION
[
    {
        "name": "app",
        "image": "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1",
        "cpu": 256,
        "memory": 512,
        "secrets": [
            {"name": "DB_HOST", "valueFrom": "${aws_secretsmanager_secret.sbcntrMySqlSecret.arn}:host::"},
            {"name": "DB_NAME", "valueFrom": "${aws_secretsmanager_secret.sbcntrMySqlSecret.arn}:dbname::"},
            {"name": "DB_USERNAME", "valueFrom": "${aws_secretsmanager_secret.sbcntrMySqlSecret.arn}:username::"},
            {"name": "DB_PASSWORD", "valueFrom": "${aws_secretsmanager_secret.sbcntrMySqlSecret.arn}:password::"}
        ],
        "portMappings": [
            {
                "containerPort": 80
            }
        ],
        "essential": true,
        "readonlyRootFilesystem": true,
        "logConfiguration": {
            "logDriver": "awsfirelens"
        }
    },
    {
        "name": "log_router",
        "image": "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:log-router",
        "cpu": 64,
        "memory": 128,
        "essential": true,
        "user": "0",
        "firelensConfiguration": {
            "type": "fluentbit"
        },
        "environment": [
            { "name" : "APP_ID", "value" : "backend_def" },
            { "name" : "AWS_ACCOUNT_ID", "value" : "${data.aws_caller_identity.self.account_id}" },
            { "name" : "AWS_REGION", "value" : "${var.region}" },
            { "name" : "LOG_BUCKET_NAME", "value" : "${aws_s3_bucket.sbcntrApplicationLogBucket.id}" },
            { "name" : "LOG_GROUP_NAME", "value" : "${aws_cloudwatch_log_group.sbcntrBackendLog.name}" }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.sbcntrApplicationLog.name}",
                "awslogs-region": "${var.region}",
                "awslogs-stream-prefix": "firelens"
            }
        },
        "firelensConfiguration": {
            "type": "fluentbit",
            "options": {
                "config-file-type": "file",
                "config-file-value": "/fluent-bit/custom.conf"
            }
        }
    }
]
TASK_DEFINITION

}
