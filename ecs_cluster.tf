resource "aws_ecs_cluster" "sbcntrEcsBackendCluster" {
  name = "sbcntr-ecs-backend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster" "sbcntrECSClusterFrontend" {
  name = "sbcntr-ecs-frontend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
