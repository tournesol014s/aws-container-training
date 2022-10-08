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
