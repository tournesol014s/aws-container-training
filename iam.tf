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
