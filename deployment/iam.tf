resource "aws_iam_role" "main" {
  name = format("%s-%s", var.project_name, var.region)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = format("%s-%s", var.project_name, var.region)
  role = aws_iam_role.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ssm:GetParameter",
          "dynamodb:*",
          "sqs:*",
          "sns:*",
          "s3:*"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
    ]
  })
}