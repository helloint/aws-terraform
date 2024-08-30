provider "aws" {
  region = var.region
}

#https://developer.hashicorp.com/terraform/language/settings/backends/s3
terraform {
  // Not using the latest version is because the latest macOS(darwin_arm64) version is v1.1.6
  required_version = "~> 1.1"

  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/4.40.0
      source  = "hashicorp/aws"
      version = "~> 4.40"
    }
  }
}

locals {
  bucket_name   = var.bucket_name
  lambda_name   = var.lambda_name
  schedule_name = var.schedule_name
  schedule_cron = var.schedule_cron
}

module "lambda_bucket" {
  source    = "./modules/s3"
  s3_bucket = local.bucket_name
}

module "lambda_role" {
  source      = "./modules/lambda-role"
  lambda_name = local.bucket_name
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/../project/${local.lambda_name}.js"
  output_path = "${path.module}/../project/deployables/${local.lambda_name}.zip"
}

module "lambda_data" {
  source           = "./modules/lambda"
  function_name    = local.lambda_name
  function_handler = "${local.lambda_name}.handler"
  role_arn         = module.lambda_role.lambda_role_arn
  zip_filename     = data.archive_file.lambda_archive.output_path
  zip_filehash     = data.archive_file.lambda_archive.output_base64sha256
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = local.schedule_name
  description         = "Schedule for Lambda Function"
  schedule_expression = local.schedule_cron
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda_data"
  arn       = module.lambda_data.arn
}

resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_data.function_name
  principal     = "events.amazonaws.com"
}

data "archive_file" "lambda_isodd" {
  type        = "zip"
  source_file = "${path.module}/../isodd-lambda/dist/index.js"
  output_path = "${path.module}/../isodd-lambda/dist/index.zip"
}

#Create our lambda function
resource "aws_lambda_function" "is-odd" {
  filename      = data.archive_file.lambda_isodd.output_path
  source_code_hash = data.archive_file.lambda_isodd.output_base64sha256
  function_name = "is-odd"
  handler       = "index.handler"
  role          = module.lambda_role.lambda_role_arn
  runtime = "nodejs18.x"
  layers = [aws_lambda_layer_version.is-odd_layer.arn]
}

resource "aws_lambda_layer_version" "is-odd_layer" {
  filename   = "${path.module}/../isodd-lambda/nodejs.zip"
  layer_name = "is-odd_layer"
  compatible_runtimes = ["nodejs18.x"]
}
