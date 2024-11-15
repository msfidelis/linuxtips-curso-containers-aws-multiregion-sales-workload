resource "aws_sns_topic_subscription" "primary_to_secondary" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = data.aws_sns_topic.primary.arn
  endpoint             = data.aws_sqs_queue.secondary.arn
}

resource "aws_sns_topic_subscription" "secondary_to_primary" {
  provider             = aws.secondary
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = data.aws_sns_topic.secondary.arn
  endpoint             = data.aws_sqs_queue.primary.arn
}