resource "aws_dynamodb_table" "idempotency" {

  name           = lookup(var.dynamodb_idempotency, "name")
  read_capacity  = lookup(var.dynamodb_idempotency, "read_min")
  write_capacity = lookup(var.dynamodb_idempotency, "write_min")

  billing_mode = lookup(var.dynamodb_idempotency, "billing_mode")

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  // DynamoDB Streams
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  point_in_time_recovery {
    enabled = lookup(var.dynamodb_idempotency, "point_in_time_recovery")
  }

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
      replica
    ]
  }


}

resource "aws_appautoscaling_target" "idempotency_read" {
  max_capacity = lookup(var.dynamodb_idempotency, "read_max")
  min_capacity = lookup(var.dynamodb_idempotency, "read_min")

  resource_id        = format("table/%s", aws_dynamodb_table.idempotency.id)
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "idempotency_read" {
  name = format("%s-autoscaling-read", aws_dynamodb_table.idempotency.id)

  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.idempotency_read.resource_id
  scalable_dimension = aws_appautoscaling_target.idempotency_read.scalable_dimension
  service_namespace  = aws_appautoscaling_target.idempotency_read.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = lookup(var.dynamodb_idempotency, "read_autoscale_threshold")
  }

}


resource "aws_appautoscaling_target" "idempotency_write" {
  max_capacity = lookup(var.dynamodb_idempotency, "write_max")
  min_capacity = lookup(var.dynamodb_idempotency, "write_min")

  resource_id        = format("table/%s", aws_dynamodb_table.idempotency.id)
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "idempotency_write" {
  name = format("%s-autoscaling-write", aws_dynamodb_table.idempotency.id)

  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.idempotency_write.resource_id
  scalable_dimension = aws_appautoscaling_target.idempotency_write.scalable_dimension
  service_namespace  = aws_appautoscaling_target.idempotency_write.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = lookup(var.dynamodb_idempotency, "write_autoscale_threshold")
  }

}

resource "aws_dynamodb_table_replica" "idempotency" {
  provider = aws.secondary

  global_table_arn = aws_dynamodb_table.idempotency.arn

  depends_on = [
    aws_appautoscaling_policy.idempotency_read,
    aws_appautoscaling_policy.idempotency_write
  ]
}