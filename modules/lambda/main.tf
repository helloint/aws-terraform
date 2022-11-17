variable "function_name" {}
variable "role_arn" {}
variable "zip_filename" {}
variable "zip_filehash" {}
variable "function_handler" {}
variable "layer" {
  default = ""
}

resource "aws_lambda_function" "function" {
  filename         = var.zip_filename
  source_code_hash = var.zip_filehash
  function_name    = var.function_name
  handler          = var.function_handler
  role             = var.role_arn
  runtime          = "nodejs12.x"
  layers           = var.layer == "" ? [] : [var.layer]
}

output "arn" {
  value = aws_lambda_function.function.arn
}

output "invoke_arn" {
  value = aws_lambda_function.function.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.function.function_name
}
