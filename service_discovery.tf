resource "aws_service_discovery_private_dns_namespace" "sbcntrEcsBackendService" {
  name = "local"
  vpc  = aws_vpc.sbcntrVpc.id
}

resource "aws_service_discovery_service" "sbcntrEcsBackendService" {
  name = "sbcntr-ecs-backend-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.sbcntrEcsBackendService.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
