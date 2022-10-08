resource "aws_cloudwatch_log_group" "sbcntrBackendLog" {
  name              = "/ecs/sbcntr-backend"
  retention_in_days = 14

  tags = {
    Name = "sbcntr-backend-log"
  }
}

resource "aws_cloudwatch_log_group" "sbcntrFrontendLog" {
  name              = "/ecs/sbcntr-frontend"
  retention_in_days = 14

  tags = {
    Name = "sbcntr-frontend-log"
  }
}
