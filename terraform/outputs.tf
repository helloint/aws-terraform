output "lambda_name" {
  value = module.lambda_data.function_name
}

output "lambda_arn" {
  value = module.lambda_data.arn
}

output "lambda_role_arn" {
  value = module.lambda_role.lambda_role_arn
}

output "bucket_arn" {
  value = module.lambda_bucket.arn
}

output "domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
