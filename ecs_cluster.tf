resource "aws_ecs_cluster" "sbcntrEcsBackendCluster" {
  name = "sbcntr-ecs-backend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
