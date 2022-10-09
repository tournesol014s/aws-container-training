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
