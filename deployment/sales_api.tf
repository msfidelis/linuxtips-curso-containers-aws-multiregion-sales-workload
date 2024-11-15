module "sales_api" {
  source = "github.com/msfidelis/linuxtips-curso-containers-ecs-service-module?ref=v1.5"

  region       = var.region
  cluster_name = var.cluster_name

  service_name   = "sales-api-${var.region}"
  service_port   = "8080"
  service_cpu    = 256
  service_memory = 512

  task_minimum = 1
  task_maximum = 3

  service_task_count = 1


  container_image = "fidelissauro/sales-rest-api:latest"

  service_listener = data.aws_ssm_parameter.listener.value
  alb_arn          = data.aws_ssm_parameter.alb.value

  service_task_execution_role = aws_iam_role.main.arn

  service_healthcheck = {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 60
    matcher             = "200-399"
    path                = "/healthcheck"
    port                = 8080
  }

  service_launch_type = [{
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }]

  deployment_controller = "ECS"

  service_hosts = [
    "sales.msfidelis.com.br"
  ]

  vpc_id = data.aws_ssm_parameter.vpc.value

  private_subnets = [
    data.aws_ssm_parameter.subnet_1.value,
    data.aws_ssm_parameter.subnet_2.value,
    data.aws_ssm_parameter.subnet_3.value,
  ]

  environment_variables = [
    {
      name  = "AWS_REGION"
      value = var.region
    },
    {
      name  = "SNS_SALES_PROCESSING_TOPIC"
      value = aws_sns_topic.main.arn
    },
    {
      name  = "SSM_PARAMETER_STORE_STATE"
      value = var.parameter_store_state_name
    },
    {
      name  = "DYNAMO_SALES_TABLE"
      value = var.sales_table_name
    }
  ]
}