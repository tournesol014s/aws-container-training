##############################
# For BlueGreen Deployment
##############################
data "aws_iam_policy_document" "codeDeployAssumeRole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codeDeployRole" {
  name               = "codeDeployRole"
  assume_role_policy = data.aws_iam_policy_document.codeDeployAssumeRole.json
}

resource "aws_iam_role_policy_attachment" "codeDeployRolePolicy" {
  role       = aws_iam_role.codeDeployRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

##############################
# For ECS Task Execution
##############################
data "aws_iam_policy_document" "ecsTaskAssumeRole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecsTaskAssumeRole.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRolePolicyAttachment" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRoleGettingSecretsPolicyAttachment" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.sbcntrGettingSecretsPolicy.arn
}

resource "aws_iam_policy" "sbcntrGettingSecretsPolicy" {
  name   = "sbcntr-GettingSecretsPolicy"
  policy = data.aws_iam_policy_document.sbcntrGettingSecretsPolicyDocument.json
}

data "aws_iam_policy_document" "sbcntrGettingSecretsPolicyDocument" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
    sid       = "GetSecretForECS"
  }
}

##############################
# For RDS Enhanced Monitoring
##############################
data "aws_iam_policy_document" "rdsMonitoringAssumeRole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rdsMonitoringRole" {
  name               = "rdsMonitoringRole"
  assume_role_policy = data.aws_iam_policy_document.rdsMonitoringAssumeRole.json
}

resource "aws_iam_role_policy_attachment" "rdsMonitoringolePolicy" {
  role       = aws_iam_role.rdsMonitoringRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


##############################
# For Code Build
##############################
data "aws_iam_policy_document" "codeBuildAssumeRole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sbcntrCodeBuildRole" {
  name               = "sbcntr-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codeBuildAssumeRole.json
}

resource "aws_iam_role_policy_attachment" "sbcntrCodeBuildRolePolicyAttachmentByECRRepositoryPolicy" {
  role       = aws_iam_role.sbcntrCodeBuildRole.name
  policy_arn = aws_iam_policy.sbcntrAccessingECRRepositoryPolicy.arn
}

resource "aws_iam_role_policy_attachment" "sbcntrCodeBuildRolePolicyAttachmentByCodeBuildBasePolicy" {
  role       = aws_iam_role.sbcntrCodeBuildRole.name
  policy_arn = aws_iam_policy.sbcntrCodebuildBasePolicy.arn
}

resource "aws_iam_policy" "sbcntrCodebuildBasePolicy" {
  name        = "sbcntr-codebuild-base-policy"
  path        = "/"
  description = "sbcntr-codebuild-base-policy"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/sbcntr-codebuild",
                "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/sbcntr-codebuild:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::sbcntr-codepipeline/*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:codecommit:${var.region}:${data.aws_caller_identity.self.account_id}:sbcntr-backend"
            ],
            "Action": [
                "codecommit:GitPull"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.self.account_id}:report-group/sbcntr-codebuild-*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "sbcntrAccessingECRRepositoryPolicy" {
  name        = "sbcntr-AccessingECRRepositoryPolicyForCodeBuild"
  path        = "/"
  description = "sbcntr-AccessingECRRepositoryPolicyyForCodeBuild"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListImagesInRepository",
            "Effect": "Allow",
            "Action": [
                "ecr:ListImages"
            ],
            "Resource": [
                "arn:aws:ecr:${var.region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-backend",
                "arn:aws:ecr:${var.region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-frontend",
                "arn:aws:ecr:${var.region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-base"
            ]
        },
        {
            "Sid": "GetAuthorizationToken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageRepositoryContents",
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": [
                "arn:aws:ecr:${var.region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-backend",
                "arn:aws:ecr:${var.region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-frontend",
                "arn:aws:ecr:${var.region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-base"
            ]
        }
    ]
}
POLICY
  tags = {
    Name = "sbcntr-AccessingECRRepositoryPolicyForCodeBuild"
  }
}

##############################
# For Code Pipeline
##############################
data "aws_iam_policy_document" "codePipelineAssumeRole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sbcntrCodePipelineRole" {
  name               = "sbcntr-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codePipelineAssumeRole.json
}

resource "aws_iam_role_policy_attachment" "sbcntrCodePipelineRolePolicyAttachment" {
  role       = aws_iam_role.sbcntrCodePipelineRole.name
  policy_arn = aws_iam_policy.sbcntrCodePipelineBasePolicy.arn
}

resource "aws_iam_policy" "sbcntrCodePipelineBasePolicy" {
  name        = "sbcntr-codepipeline-base-policy"
  path        = "/"
  description = "sbcntr-codepipeline-base-policy"
  policy      = <<POLICY
{
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "${aws_iam_role.ecsTaskExecutionRole.arn}",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetApplication",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
POLICY
}

##############################
# For Code Pipeline CloudWatch Event
##############################
data "aws_iam_policy_document" "cloudWatchEventAssumeRole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sbcntrCodePipelineCloudWatchEventRole" {
  name               = "sbcntr-pipeline-cludwatch-event-role"
  assume_role_policy = data.aws_iam_policy_document.cloudWatchEventAssumeRole.json
}

resource "aws_iam_role_policy_attachment" "sbcntrCodePipelineCloudWatchEventRolePolicyAttachment" {
  role       = aws_iam_role.sbcntrCodePipelineCloudWatchEventRole.name
  policy_arn = aws_iam_policy.sbcntrCodePipelineCloudWatchEventPolicy.arn
}

resource "aws_iam_policy" "sbcntrCodePipelineCloudWatchEventPolicy" {
  name        = "sbcntr-codepipeline-cloudwatch-event-policy"
  path        = "/"
  description = "sbcntr-codepipeline-cloudwatch-event-policy"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codepipeline:StartPipelineExecution"
            ],
            "Resource": [
                "arn:aws:codepipeline:${var.region}:${data.aws_caller_identity.self.account_id}:${aws_codepipeline.sbcntrPipeline.name}"
            ]
        }
    ]
}
POLICY
}


##############################
# For Log Router
##############################
resource "aws_iam_role" "sbcntrECSTaskRole" {
  name               = "sbcntr-ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecsTaskAssumeRole.json
}

resource "aws_iam_role_policy_attachment" "sbcntrECSTaskRolePolicyAttachment" {
  role       = aws_iam_role.sbcntrECSTaskRole.name
  policy_arn = aws_iam_policy.sbcntrAccessingLogDestination.arn
}

resource "aws_iam_policy" "sbcntrAccessingLogDestination" {
  name        = "sbcntr-AccessingLogDestination"
  path        = "/"
  description = "sbcntr-AccessingLogDestination"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.sbcntrApplicationLogBucket.arn}",
        "${aws_s3_bucket.sbcntrApplicationLogBucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["kms:Decrypt", "kms:GenerateDataKey"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Resource": ["*"]
    }
  ]
}
POLICY
}
