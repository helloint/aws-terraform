variable "s3_bucket" {
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket
}

resource "aws_s3_account_public_access_block" "s3_bucket_access" {
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

output "id" {
  value = aws_s3_bucket.s3_bucket.id
}

output "arn" {
  value = aws_s3_bucket.s3_bucket.arn
}

output "name" {
  value = aws_s3_bucket.s3_bucket.bucket
}

output "regional_domain_name" {
  value = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
}
