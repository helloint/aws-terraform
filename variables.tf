variable "task_name" {
  default = "project"
}

variable "bucket_name" {
  default = "tf-bucket"
}

variable "lambda_name" {
  default = "processData"
}

variable "schedule_name" {
  default = "tf_schedule"
}

variable "schedule_cron" {
  default = "cron(0/10 * ? * * *)"
}
