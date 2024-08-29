# aws-terraform
Terraform to maintain AWS resources: Lambda + S3 + CloudFront + CloudWatch + CodePipeline(TODO)

## Environment
* Install `tfenv`: ```brew install tfenv```
* Install Terraform: ```tfenv install```
* Install AWS CLI: See [Official Document](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Credentials
`~/.aws/credentials`
```
[default]
aws_access_key_id = XXX
aws_secret_access_key = XXX
```

## Setup
1. First you need to have an AWS account with proper rules in order to create required resources.
2. Go to `terraform/setup/` folder, generate resources that remote terraform state requires.
```shell
cd terraform/setup
terraform init
terraform apply -auto-approve
```
3. Go to parent folder, generate resources.
```shell
cd ..
terraform init -backend-config=backend.conf
terraform apply -auto-approve
```
## Destroy
```shell
terraform apply -destroy -auto-approve
```

## Reference
[tfenv](https://github.com/tfutils/tfenv)
[Terraform CLI](https://developer.hashicorp.com/terraform/cli/commands/apply)
[AWS Console](https://us-east-1.console.aws.amazon.com/s3/home?region=us-east-1)

## TODO
1. Convert to ESModule
2. Introduce npm project
3. Upgrade to AWS CLI v3
