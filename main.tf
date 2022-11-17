terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }
  backend "s3" {
    region         = "ap-northeast-1"
    key            = "terraform.wnba.tfstate"
    bucket         = "tf-wnba-terraform-state-lock"
    dynamodb_table = "tf-wnba-terraform-state-lock"
    encrypt        = true
  }
}

variable "region" {
  default = "ap-northeast-1"
}

variable "bucket_name" {
  default = "tf-wnba-data"
}

variable "lambda_name" {
  default = "persistWNBADataTF"
}

variable "schedule" {
  default = "cron(0/10 * ? * MON-FRI *)"
}

provider "aws" {
  region = var.region
}

locals {
  bucket_name   = var.bucket_name
  lambda_name   = var.lambda_name
  function_name = "persistWNBAData"
  zip_file_name = "${path.module}/deployables/persistWNBAData.zip"
  handler_name  = "persistWNBAData.handler"
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
  source_file = "${path.module}/persistWNBAData.js"
  output_path = "${path.module}/deployables/persistWNBAData.zip"
}

module "persist_wnba_data_lambda" {
  source           = "./modules/lambda"
  function_name    = local.lambda_name
  function_handler = local.handler_name
  role_arn         = module.lambda_role.lambda_role_arn
  zip_filename     = local.zip_file_name
  zip_filehash     = data.archive_file.lambda_archive.output_base64sha256
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "tf_wnba_schedule"
  description         = "Schedule for Lambda Function"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "persist_wnba_data_lambda"
  arn       = module.persist_wnba_data_lambda.arn
}

resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.persist_wnba_data_lambda.function_name
  principal     = "events.amazonaws.com"
}

output "lambda_name" {
  value = module.persist_wnba_data_lambda.function_name
}
output lambda_arn {
  value = module.persist_wnba_data_lambda.arn
}
output "lambda_role_arn" {
  value = module.lambda_role.lambda_role_arn
}
output "bucket_arn" {
  value = module.lambda_bucket.arn
}
