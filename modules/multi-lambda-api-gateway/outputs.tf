output "api_id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "API Gateway ID"
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}

output "rest_api_url" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.this.stage_name}"
}

output "api_key_value" {
  value = aws_api_gateway_api_key.default.value
}
