resource "aws_codepipeline" "sbcntrPipeline" {
  name     = "sbcntr-pipeline"
  role_arn = aws_iam_role.sbcntrCodePipelineRole.arn

  artifact_store {
    location = aws_s3_bucket.sbcntrCodepipelineBucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      namespace        = "SourceVariables"

      configuration = {
        RepositoryName       = "sbcntr-backend"
        BranchName           = "main"
        PollForSourceChanges = "false"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = "sbcntr-codebuild"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["BuildArtifact", "SourceArtifact"]
      version         = "1"
      namespace       = "DeployVariables"

      configuration = {
        ApplicationName                = "sbcntr-backend"
        DeploymentGroupName            = "sbcntr-ecs-backend-deployment-group"
        TaskDefinitionTemplateArtifact = "SourceArtifact"
        AppSpecTemplateArtifact        = "SourceArtifact"
        Image1ArtifactName             = "BuildArtifact"
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }
}

resource "aws_s3_bucket" "sbcntrCodepipelineBucket" {
  bucket = "sbcntr-codepipeline"
}

resource "aws_s3_bucket_acl" "sbcntrCodepipelineBucket" {
  bucket = aws_s3_bucket.sbcntrCodepipelineBucket.bucket
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sbcntrCodepipelineBucket" {
  bucket = aws_s3_bucket.sbcntrCodepipelineBucket.bucket

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudwatch_event_rule" "sbcntrCodePipelinePushRepository" {
  name        = "sbcntr-code-pipeline-push-repository"
  description = "sbcntr-code-pipeline-push-repository"

  event_pattern = <<EOF
{
  "source": ["aws.codecommit"],
  "detail-type": ["CodeCommit Repository State Change"],
  "resources": ["${aws_codecommit_repository.sbcntrBackend.arn}"],
  "detail": {
    "event": ["referenceCreated", "referenceUpdated"],
    "referenceType": ["branch"],
    "referenceName": ["main"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "sbcntrCodePipelinePushRepository" {
  rule     = aws_cloudwatch_event_rule.sbcntrCodePipelinePushRepository.name
  arn      = aws_codepipeline.sbcntrPipeline.arn
  role_arn = aws_iam_role.sbcntrCodePipelineCloudWatchEventRole.arn
}
