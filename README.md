# aws-terraform
Terraform to maintain AWS resources: Lambda + S3 + CloudFront + CloudWatch + CodePipeline(TODO)

## Environment
* Terraform install `brew install terraform`
* [AWS CLI install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Credentials
`~/.aws/credentials`
```
[default]
aws_access_key_id = XXX
aws_secret_access_key = XXX
```

## Steps
1. First you need to have an AWS account with proper rules to create required resources.
2. run `terraform init`,`terraform apply --auto-approve` in `setup` folder to generate resources that remote terraform state requires.
3. run `terraform init`,`terraform apply --auto-approve` in root folder to generate resources.
