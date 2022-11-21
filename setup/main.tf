variable "state_locking_bucket_name" {
  default = "tf-terraform-state-lock"
}

variable "state_locking_db_name" {
  default = "tf-terraform-state-lock"
}

resource "aws_dynamodb_table" "state_locking" {
  hash_key = "LockID"
  name     = var.state_locking_db_name
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}

module "state_bucket" {
  source    = "../modules/s3"
  s3_bucket = var.state_locking_bucket_name
}
