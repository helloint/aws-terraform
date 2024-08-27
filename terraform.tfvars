region = "ap-northeast-1"

task_name = "hint-demo"
bucket_name = "tf-hint-demo-data"
lambda_name = "persistData"
schedule_name = "tf_hint-demo_schedule"
schedule_cron = "cron(0/10 * ? * * *)"
