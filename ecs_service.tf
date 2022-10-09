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
