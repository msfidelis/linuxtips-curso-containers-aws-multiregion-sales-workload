data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpc" {
  name = var.ssm_vpc_id
}

data "aws_ssm_parameter" "subnet_1" {
  name = var.ssm_private_subnet_1
}

data "aws_ssm_parameter" "subnet_2" {
  name = var.ssm_private_subnet_2
}

data "aws_ssm_parameter" "subnet_3" {
  name = var.ssm_private_subnet_3
}

data "aws_ssm_parameter" "alb" {
  name = var.ssm_alb
}

data "aws_ssm_parameter" "listener" {
  name = var.ssm_listener
}