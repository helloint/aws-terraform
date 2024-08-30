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

resource "aws_api_gateway_rest_api" "is-odd-api" {
  name = "is-odd-api"
  description = "Created by Terraform"

  # No this configuration will lead to exception, not sure if it is because of the edge not sync yet.
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "is-odd-resource" {
  rest_api_id = aws_api_gateway_rest_api.is-odd-api.id
  parent_id   = aws_api_gateway_rest_api.is-odd-api.root_resource_id
  path_part   = "is-odd"
}

resource "aws_api_gateway_method" "is-odd-method" {
  rest_api_id   = aws_api_gateway_rest_api.is-odd-api.id
  resource_id   = aws_api_gateway_resource.is-odd-resource.id
  http_method   = "ANY" # GET is standard which match the function method, but ANY also works
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "is-odd-integration" {
  rest_api_id = aws_api_gateway_rest_api.is-odd-api.id
  resource_id = aws_api_gateway_resource.is-odd-resource.id
  http_method = aws_api_gateway_method.is-odd-method.http_method
  integration_http_method = "POST" # Has to be POST
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.is-odd.invoke_arn
}

resource "aws_lambda_permission" "is-odd-api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.is-odd.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.is-odd-api.execution_arn}/*/*" # Can add suffix /is-odd but without it still works
}

resource "aws_api_gateway_deployment" "is-odd-deployment" {
  depends_on = [aws_api_gateway_integration.is-odd-integration]

  rest_api_id = aws_api_gateway_rest_api.is-odd-api.id
  stage_name  = "default"
}

output "invoke_url" {
  value = aws_api_gateway_deployment.is-odd-deployment.invoke_url
}
