resource "aws_codebuild_project" "sbcntrCodebuild" {
  name          = "sbcntr-codebuild"
  badge_enabled = true

  source {
    type     = "CODECOMMIT"
    location = "https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/sbcntr-backend"
  }

  source_version = "refs/heads/main"

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  service_role = aws_iam_role.sbcntrCodeBuildRole.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

}
