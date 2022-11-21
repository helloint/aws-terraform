task_name = "wnba"

bucket_name = "tf-wnba-data"

lambda_name = "persistWNBAData"

schedule_name = "tf_wnba_schedule"

schedule_cron = "cron(0/10 * ? * * *)"
