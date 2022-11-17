variable "lambda_name" {}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role.${var.lambda_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    sid = ""
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "lambda_role_policy.${var.lambda_name}"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.role_policy.json
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["*"]
  }
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
