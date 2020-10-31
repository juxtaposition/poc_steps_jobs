# PoC AWS Batch Jobs and Step Functions
PoC for Use AWS Batch Jobs with AWS Step Functions. 

# Get Started
This PoC create a simple lambda using serverless. For that before to deploy the terraform changes create the lambda with:
```sh
$ sls deploy --stage dev --region REGION --profile PROFILE
```
After that this PoC need for a VPC and public subnets. please create this records in your aws dashboard: 
See [example](https://www.assistanz.com/creating-vpc-public-private-subnets/)

After the lambda and VPC and Subnets are created set the values into the variables.tf

| Variable | Value |
| ------ | ------ |
| aws_account_id | Your aws account id |
| vcp_id | VPC ID |
| batch_job_subnets | Public subnet id |

Deploy your change with terraform:
Terraform version: terraform-0_12_29

```sh
$ terraform plan
$ terraform apply
```

Go to AWS Dashboard and seach for step function services. and submite a new job: See [example](https://docs.aws.amazon.com/step-functions/latest/dg/tutorial-creating-lambda-state-machine.html#create-lambda-state-machine-step-5)
