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
