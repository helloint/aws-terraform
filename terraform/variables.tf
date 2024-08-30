variable "region" {
  default = "us-east-1"
}

variable "task_name" {
  default = "project"
}

variable "bucket_name" {
  default = "tf-bucket"
}

variable "lambda_name" {
  default = "index"
}

variable "schedule_name" {
  default = "tf_schedule"
}

variable "schedule_cron" {
  default = "cron(0/10 * ? * * *)"
}
