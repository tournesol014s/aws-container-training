resource "aws_ecs_task_definition" "sbcntrBackendDef" {
  family                   = "sbcntr-backend-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<TASK_DEFINITION
[
    {
        "name": "app",
        "image": "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1",
        "cpu": 256,
        "memory": 512,
        "portMappings": [
            {
                "containerPort": 80
            }
        ],
        "essential": true,
        "readonlyRootFilesystem": true,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/sbcntr-backend",
                "awslogs-region": "ap-northeast-1",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]
TASK_DEFINITION

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
        "image": "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:v1",
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
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/sbcntr-frontend",
                "awslogs-region": "ap-northeast-1",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]
TASK_DEFINITION

}
