resource "aws_dynamodb_table" "sales" {

  name           = lookup(var.dynamodb_sales, "name")
  read_capacity  = lookup(var.dynamodb_sales, "read_min")
  write_capacity = lookup(var.dynamodb_sales, "write_min")

  billing_mode = lookup(var.dynamodb_sales, "billing_mode")

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  // DynamoDB Streams
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  point_in_time_recovery {
    enabled = lookup(var.dynamodb_sales, "point_in_time_recovery")
  }

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
      replica
    ]
  }


}

resource "aws_appautoscaling_target" "sales_read" {
  max_capacity = lookup(var.dynamodb_sales, "read_max")
  min_capacity = lookup(var.dynamodb_sales, "read_min")

  resource_id        = format("table/%s", aws_dynamodb_table.sales.id)
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "sales_read" {
  name = format("%s-autoscaling-read", aws_dynamodb_table.sales.id)

  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sales_read.resource_id
  scalable_dimension = aws_appautoscaling_target.sales_read.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sales_read.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = lookup(var.dynamodb_sales, "read_autoscale_threshold")
  }

}


resource "aws_appautoscaling_target" "sales_write" {
  max_capacity = lookup(var.dynamodb_sales, "write_max")
  min_capacity = lookup(var.dynamodb_sales, "write_min")

  resource_id        = format("table/%s", aws_dynamodb_table.sales.id)
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "sales_write" {
  name = format("%s-autoscaling-write", aws_dynamodb_table.sales.id)

  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sales_write.resource_id
  scalable_dimension = aws_appautoscaling_target.sales_write.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sales_write.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = lookup(var.dynamodb_sales, "write_autoscale_threshold")
  }

}

resource "aws_dynamodb_table_replica" "sales" {
  provider = aws.secondary

  global_table_arn = aws_dynamodb_table.sales.arn

  depends_on = [
    aws_appautoscaling_policy.sales_read,
    aws_appautoscaling_policy.sales_write
  ]
}