provider "aws" {
  region = "eu-west-2"
}

data "aws_connect_instance" "default" {
  instance_alias = "eastghats-dev"
}

locals {
  amplify_app_id = "d1b8m7s8f6rgmd"
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
  role_name     = "eastghats-ccp-lambda-role-dev"
  force_create  = true

  tags = {
    Project     = "eastghats-ccp"
    Environment = "dev"
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
    STAGE = "dev"
    CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
  }
  tags = {
    Project     = "eastghats-ccp"
    Environment = "dev"
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
    STAGE = "dev"
    CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
  }
  tags = {
    Project     = "eastghats-ccp"
    Environment = "dev"
  }
}

module "api_gateway" {
  source = "../../modules/multi-lambda-api-gateway"
  name   = "eastghats-ccp-api-dev"

  routes = {
    "/getRoutingProfiles"     = { method = "POST", lambda_uri = module.get_profiles_ccp.lambda_uri },
    "/updateRoutingProfiles"  = { method = "POST", lambda_uri = module.update_profiles_ccp.lambda_uri }
  }

  tags = {
    Project     = "eastghats-ccp"
    Environment = "dev"
  }
}

module "amplify_app" {
  source = "../../modules/amplify"

  app_name   = "customccp-ui"
  repo_url   = "https://github.com/support-eastghats/customccp-ui"
  github_token = var.github_token
  branch_name = "dev"
  stage       = "development"

  environment_variables = {
    REACT_APP_ENV = "development"
  }

  build_spec = file("${path.module}/buildspec.yml")

  tags = {
    Environment = "dev"
    Project     = "custom-ccp"
  }
}