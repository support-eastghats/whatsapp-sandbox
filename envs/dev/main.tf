# envs/dev/main.tf

provider "aws" {
  region = "ap-south-1"
}

locals {
  amplify_app_id  = "d1b8m7s8f6rgmd"
}

variable "github_token" {
  description = "GitHub Token for Amplify app"
  type        = string
  sensitive   = true
  default     = ""
}

# Archive packaging for Lambdas
data "archive_file" "register_number_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-code/registerNumber"
  output_path = "${path.module}/../../lambda-code/registerNumber.zip"
}

data "archive_file" "send_message_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-code/sendMessage"
  output_path = "${path.module}/../../lambda-code/sendMessage.zip"
}

data "archive_file" "receive_webhook_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-code/receiveWebhook"
  output_path = "${path.module}/../../lambda-code/receiveWebhook.zip"
}

module "iam" {
  source       = "../../modules/iam"
  role_name    = "eastghats-whatsapp-lambda-role-dev"
  force_create = true

  tags = {
    Project     = "eastghats-whatsapp"
    Environment = "sandbox"
  }
}

module "shared_layer" {
  source = "../../modules/lambda-layer"
}

module "register_Number" {
  source               = "../../modules/lambda"
  function_name        = "whatsapp-registerNumber"
  handler              = "index.handler"
  lambda_zip_path      = data.archive_file.register_number_zip.output_path
  lambda_role_arn      = module.iam.lambda_exec_role_arn
  lambda_layer_arn     = module.shared_layer.layer_arn
  api_gateway_id       = module.api_gateway.api_id
  api_gateway_execution_arn = module.api_gateway.execution_arn
  env_vars = {
    STAGE = "dev"
  }
  tags = {
    Project     = "eastghats-whatsapp"
    Environment = "sandbox"
  }
  depends_on = [data.archive_file.register_number_zip]
}

resource "aws_lambda_permission" "register_Number_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetAvailableProfiles"
  action        = "lambda:InvokeFunction"
  function_name = module.register_Number.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/*"
}

module "send_Message" {
  source               = "../../modules/lambda"
  function_name        = "whatsapp-send-message"
  handler              = "index.handler"
  lambda_zip_path      = data.archive_file.send_message_zip.output_path
  lambda_role_arn      = module.iam.lambda_exec_role_arn
  lambda_layer_arn     = module.shared_layer.layer_arn
  api_gateway_id       = module.api_gateway.api_id
  api_gateway_execution_arn = module.api_gateway.execution_arn
  env_vars = {
    STAGE = "dev"
  }
  tags = {
    Project     = "eastghats-whatsapp"
    Environment = "sandbox"
  }
  depends_on = [data.archive_file.send_message_zip]
}

resource "aws_lambda_permission" "send_Message_permission" {
  statement_id  = "AllowAPIGatewayInvokeSwitchRoutingProfile"
  action        = "lambda:InvokeFunction"
  function_name = module.send_Message.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/*"
}

module "receive_Webhook" {
  source               = "../../modules/lambda"
  function_name        = "whatsapp-receiveWebhook"
  handler              = "index.handler"
  lambda_zip_path      = data.archive_file.receive_webhook_zip.output_path
  lambda_role_arn      = module.iam.lambda_exec_role_arn
  lambda_layer_arn     = module.shared_layer.layer_arn
  api_gateway_id       = module.api_gateway.api_id
  api_gateway_execution_arn = module.api_gateway.execution_arn
  env_vars = {
    STAGE = "dev"
  }
  tags = {
    Project     = "eastghats-whatsapp"
    Environment = "sandbox"
  }
  depends_on = [data.archive_file.receive_webhook_zip]
}

resource "aws_lambda_permission" "receive_Webhook_permission" {
  statement_id  = "AllowAPIGatewayInvokeSetPauseResumeAttr"
  action        = "lambda:InvokeFunction"
  function_name = module.receive_Webhook.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/*"
}

module "api_gateway" {
  source     = "../../modules/multi-lambda-api-gateway"
  name       = "eastghats-whatsapp-api-dev"
  stage_name = "dev"

  routes = {
    "registerNumber"  = { path = "/registerNumber", method = "POST", lambda_uri = module.register_Number.lambda_uri },
    "sendMessage"      = { path = "/sendMessage", method = "POST", lambda_uri = module.send_Message.lambda_uri },
    "receiveWebhook"   = { path = "/receiveWebhook", method = "PUT",  lambda_uri = module.receive_Webhook.lambda_uri }
  }

  tags = {
    Project     = "eastghats-whatsapp"
    Environment = "sandbox"
  }
}

module "amplify_app" {
  source        = "../../modules/amplify"
  app_name      = "whatsapp-sandbox-ui"
  repo_url      = "https://github.com/support-eastghats/whatsapp-sandbox"
  github_token  = var.github_token
  branch_name   = "dev"
  stage         = "PRODUCTION"

  environment_variables = {
    REACT_APP_ENV       = "development"
    REACT_APP_API_URL   = module.api_gateway.rest_api_url
    REACT_APP_APIKEY    = module.api_gateway.api_key_value
    REACT_APP_REGION    = "ap-south-1"
    REACT_APP_STAGE     = "dev"
  }

  build_spec = file("${path.module}/buildspec.yml")

  tags = {
    Environment = "sandbox"
    Project     = "custom-whatsapp"
  }
}
