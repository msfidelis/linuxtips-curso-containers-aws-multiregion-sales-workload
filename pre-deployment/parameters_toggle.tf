resource "aws_ssm_parameter" "primary" {
  name  = format("/%s/site/state", var.project_name)
  type  = "String"
  value = lookup(var.active_states, var.region_primary)
}

resource "aws_ssm_parameter" "secondary" {
  provider = aws.secondary
  name     = format("/%s/site/state", var.project_name)
  type     = "String"
  value    = lookup(var.active_states, var.region_secondary)
}