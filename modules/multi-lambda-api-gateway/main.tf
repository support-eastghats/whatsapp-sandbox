resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = "Managed by Terraform"
}

resource "aws_api_gateway_resource" "root_resource" {
  for_each = var.routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.key
}

resource "aws_api_gateway_method" "proxy_methods" {
  for_each = var.routes

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.root_resource[each.key].id
  http_method   = upper(each.value.method)
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method_response" "cors_response" {
  for_each = var.routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.root_resource[each.key].id
  http_method = upper(each.value.method)
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration" "proxy_integrations" {
  for_each = var.routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.root_resource[each.key].id
  http_method = upper(each.value.method)

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_uri
}

resource "aws_api_gateway_integration_response" "integration_response" {
  for_each = var.routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.root_resource[each.key].id
  http_method = upper(each.value.method)
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'*'",
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
  }
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.proxy_integrations,
    aws_api_gateway_method.proxy_methods
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.stage_name
}

resource "aws_api_gateway_stage" "this" {
  stage_name    = var.stage_name
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
}

resource "aws_api_gateway_api_key" "default" {
  name    = "${var.name}-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "default" {
  name = "${var.name}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "default" {
  key_id        = aws_api_gateway_api_key.default.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}
