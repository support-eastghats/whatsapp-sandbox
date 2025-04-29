provider "aws" {
  region = "eu-west-2"
}

data "aws_connect_instance" "default" {
  instance_alias = "eastghats-prod"
}

data "aws_amplify_app" "existing" {
  name = "customccp-ui"
}

locals {
  connect_ccp_url = "https://${data.aws_connect_instance.default.instance_alias}.awsapps.com/connect/ccp-v2/"
}

variable "github_token" {
  description = "GitHub Token for Amplify app"
  type        = string
  sensitive   = true
  default     = ""
}

module "iam" {
  source        = "../../modules/iam"
  role_name     = "eastghats-ccp-lambda-role-prod"
  force_create  = true

  tags = {
    Project     = "eastghats-ccp"
    Environment = "prod"
  }
}

module "get_profiles_ccp" {
  source           = "../../modules/lambda"
  function_name    = "getRoutingProfiles"
  handler          = "index.handler"
  lambda_zip_path  = "../../lambda-code/getRoutingProfiles.zip"
  lambda_role_arn  = module.iam.lambda_exec_role_arn
  api_gateway_id   = module.api_gateway.api_id
  env_vars = {
    STAGE = "prod"
    CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
  }
  tags = {
    Project     = "eastghats-ccp"
    Environment = "prod"
  }
}

module "update_profiles_ccp" {
  source           = "../../modules/lambda"
  function_name    = "updateRoutingProfiles"
  handler          = "index.handler"
  lambda_zip_path  = "../../lambda-code/updateRoutingProfiles.zip"
  lambda_role_arn  = module.iam.lambda_exec_role_arn
  api_gateway_id   = module.api_gateway.api_id
  env_vars = {
    STAGE = "prod"
    CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
  }
  tags = {
    Project     = "eastghats-ccp"
    Environment = "prod"
  }
}

module "api_gateway" {
  source = "../../modules/multi-lambda-api-gateway"
  name   = "eastghats-ccp-api-prod"

  routes = {
    "/getRoutingProfiles"     = { method = "POST", lambda_uri = module.get_profiles_ccp.lambda_uri },
    "/updateRoutingProfiles"  = { method = "POST", lambda_uri = module.update_profiles_ccp.lambda_uri }
  }

  tags = {
    Project     = "eastghats-ccp"
    Environment = "prod"
  }
}

resource "aws_amplify_app_environment_variables" "update_env" {
  app_id = data.aws_amplify_app.existing.app_id

  environment_variables = {
    REACT_APP_REGION         = "eu-west-2"
    REACT_APP_CCP_URL        = local.connect_ccp_url
    REACT_APP_API_BASE_URL   = module.api_gateway.api_url
  }

  depends_on = [
    module.api_gateway
  ]
}
