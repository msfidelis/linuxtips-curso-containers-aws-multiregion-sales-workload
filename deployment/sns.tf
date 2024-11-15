resource "aws_sns_topic" "main" {
  name = format("%s", lookup(var.sqs_processing_sales_config, "queue_name"))
}

resource "aws_sns_topic_subscription" "main" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = aws_sns_topic.main.arn
  endpoint             = aws_sqs_queue.main.arn
}