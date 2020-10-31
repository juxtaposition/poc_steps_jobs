variable "aws_region" {
  default = "us-east-1"
}

variable "stage" {
  default = "dev"
}

variable "aws_account" {
  default = "default" 
}

variable "job_docker_image" {
  default = "exbios/simple_python:latest"
}

variable "aws_account_id" {
  default = ""
}

variable "vcp_id" {
  default = ""
}

variable "batch_job_subnets" {
  default = [ "" ]
}

variable "batch_job_instances_type" {
  default = [ "m5.large" ]
}

variable "batch_job_max_vcpus" {
  default = 16
}

variable "batch_job_min_vcpus" {
  default = 0
}

variable "batch_job_desire_vcpus" {
  default = 0
}
