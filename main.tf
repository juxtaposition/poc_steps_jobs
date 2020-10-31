provider "aws" {
  profile = var.aws_account
  region  = var.aws_region
}

locals {
  vcp_id = "${var.vcp_id}"
  subnets = "${var.batch_job_subnets}"
  lambda_names = toset(["pythonHello"])
  arn_lambda_prefix = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:pocJobsSteps-${var.stage}"
}

resource "aws_sns_topic" "batch_failure" {
  name = "batch_failure"
}

resource "aws_batch_job_definition" "my-heavy-function-job" {
  name = "my-heavy-function-job"
  type = "container"
  parameters = {
    country = "US"
  }
  container_properties = <<CONTAINER_PROPERTIES
{
    "command": [
      "sh",
      "/home/run.sh",
      "Ref::country"],
    "image": "${var.job_docker_image}",
    "memory": 1024,
    "vcpus": 1,
    "environment": [
        {"name": "foo", "value": "bar"}
    ]
}
CONTAINER_PROPERTIES
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  for_each = local.lambda_names

  name     = "my-state-machine"
  role_arn = aws_iam_role.iam_for_sfn.arn


  definition = <<EOF
{
  "Comment": "Testing State Machine",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "${local.arn_lambda_prefix}-${each.value}",
      "ResultPath": "$",
      "Next": "Manage Batch task"
    },
    "Manage Batch task": {
      "Type": "Task",
      "Resource": "arn:aws:states:::batch:submitJob.sync",
      "ResultPath": "$.taskresult",
      "Parameters": {
        "JobDefinition": "${aws_batch_job_definition.my-heavy-function-job.arn}",
        "JobName": "Testing-Integration",
        "JobQueue": "${aws_batch_job_queue.my-heavy-function-queue.arn}",
        "Parameters": {
          "country.$": "$.country"
        }
      },
      "Next": "Notify Success",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Notify Failure"
        }
      ]
    },
     "Notify Failure": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "InputPath": "$",
      "Parameters": {
        "Message.$": "$",
        "TopicArn": "${aws_sns_topic.batch_failure.arn}"
      },
      "End": true
    },
    "Notify Success": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "InputPath": "$",
      "Parameters": {
        "Message.$": "$",
        "TopicArn": "${aws_sns_topic.batch_failure.arn}"
      },
      "End": true
    }
  }
}
EOF
}

resource "aws_security_group" "sample" {
  name   = "aws_batch_compute_environment_security_group"
  vpc_id = local.vcp_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_batch_compute_environment" "sample" {
  compute_environment_name = "sample"

  compute_resources {
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn

    instance_type = "${var.batch_job_instances_type}"

    max_vcpus = "${var.batch_job_max_vcpus}"
    min_vcpus = "${var.batch_job_min_vcpus}"
    desired_vcpus = "${var.batch_job_desire_vcpus}"

    security_group_ids = [
      aws_security_group.sample.id,
    ]

    subnets = local.subnets

    type = "EC2"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role]
}

resource "aws_batch_job_queue" "my-heavy-function-queue" {
  name     = "my-heavy-function-queue"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    "${aws_batch_compute_environment.sample.arn}"
  ]
}
