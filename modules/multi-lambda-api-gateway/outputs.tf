
output "api_url" {
  value       = aws_apigatewayv2_api.http_api.api_endpoint
  description = "API Gateway endpoint"
}

output "api_id" {
  value = aws_apigatewayv2_api.http_api.id
}
