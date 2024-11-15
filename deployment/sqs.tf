resource "aws_sqs_queue" "dlq" {
  name = format("%s-dlq", lookup(var.sqs_processing_sales_config, "queue_name"))

  delay_seconds              = lookup(var.sqs_processing_sales_config, "delay_seconds")
  max_message_size           = lookup(var.sqs_processing_sales_config, "max_message_size")
  message_retention_seconds  = lookup(var.sqs_processing_sales_config, "message_retention_seconds")
  receive_wait_time_seconds  = lookup(var.sqs_processing_sales_config, "receive_wait_time_seconds")
  visibility_timeout_seconds = lookup(var.sqs_processing_sales_config, "visibility_timeout_seconds")
}

resource "aws_sqs_queue" "main" {
  name = format("%s", lookup(var.sqs_processing_sales_config, "queue_name"))

  delay_seconds              = lookup(var.sqs_processing_sales_config, "delay_seconds")
  max_message_size           = lookup(var.sqs_processing_sales_config, "max_message_size")
  message_retention_seconds  = lookup(var.sqs_processing_sales_config, "message_retention_seconds")
  receive_wait_time_seconds  = lookup(var.sqs_processing_sales_config, "receive_wait_time_seconds")
  visibility_timeout_seconds = lookup(var.sqs_processing_sales_config, "visibility_timeout_seconds")

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = lookup(var.sqs_processing_sales_config, "dlq_redrive_max_receive_count")
  })
}

resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id
  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.main.arn}"
      ],
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": [
            "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:*",
            "arn:aws:sns:sa-east-1:${data.aws_caller_identity.current.account_id}:*",
            "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:${lookup(var.sqs_processing_sales_config, "queue_name")}",
            "arn:aws:sns:sa-east-1:${data.aws_caller_identity.current.account_id}:${lookup(var.sqs_processing_sales_config, "queue_name")}"
          ]
        }
      }
    }
  

  ]
}
EOF
}