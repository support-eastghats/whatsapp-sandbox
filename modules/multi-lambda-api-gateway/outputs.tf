output "rest_api_id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "REST API ID"
}

output "rest_api_url" {
  value       = "https://${aws_apigatewayv2_api.http_api.id}.execute-api.${var.region}.amazonaws.com/${var.stage_name}"
  description = "Invoke URL"
}

output "api_key_value" {
  value       = aws_api_gateway_api_key.this.value
  description = "API key for clients"
  sensitive   = true
}