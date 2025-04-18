
resource "aws_apigatewayv2_api" "http_api" {
  name          = var.name
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers     = var.cors.allow_headers
    allow_methods     = var.cors.allow_methods
    allow_origins     = var.cors.allow_origins
    allow_credentials = var.cors.allow_credentials
    expose_headers    = var.cors.expose_headers
    max_age           = var.cors.max_age
  }

  tags = var.tags
}


resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each = var.routes

  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = each.value.lambda_uri
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "api_routes" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "${each.value.method} ${each.key}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integrations[each.key].id}"
}
