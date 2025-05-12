resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = "Managed by Terraform"
}

resource "aws_api_gateway_resource" "root_resource" {
  for_each   = var.routes
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = trim(each.value.path, "/")
}

# Proxy methods: POST, PUT etc.
resource "aws_api_gateway_method" "proxy_methods" {
  for_each = {
    for k, v in var.routes : k => v if upper(v.method) != "OPTIONS"
  }

  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.root_resource[each.key].id
  http_method      = upper(each.value.method)
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "proxy_integrations" {
  for_each = aws_api_gateway_method.proxy_methods

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.root_resource[each.key].id
  http_method             = upper(each.value.method)
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_uri
}

# CORS OPTIONS support (MOCK)
locals {
  unique_paths = tomap({ for k, v in var.routes : trim(v.path, "/") => aws_api_gateway_resource.root_resource[k].id })
}

resource "aws_api_gateway_method" "options" {
  for_each = local.unique_paths

  rest_api_id    = aws_api_gateway_rest_api.this.id
  resource_id    = each.value
  http_method    = "OPTIONS"
  authorization  = "NONE"
  api_key_required = false

  request_parameters = {
    "method.request.header.Origin"                         = false,
    "method.request.header.Access-Control-Request-Method" = false,
    "method.request.header.Access-Control-Request-Headers" = false
  }
}

resource "aws_api_gateway_integration" "options" {
  for_each = aws_api_gateway_method.options

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.root_resource[each.key].id
  http_method = "OPTIONS"
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  for_each = aws_api_gateway_method.options

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.root_resource[each.key].id
  http_method = "OPTIONS"
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

resource "aws_api_gateway_integration_response" "options" {
  for_each = aws_api_gateway_method.options

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.root_resource[each.key].id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,OPTIONS'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,x-api-key'"
  }

  depends_on = [
    aws_api_gateway_method.options,
    aws_api_gateway_method_response.options_response,
    aws_api_gateway_integration.options
  ]
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.proxy_integrations,
    aws_api_gateway_integration.options
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id
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
