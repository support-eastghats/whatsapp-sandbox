provider "aws" {
  region = "eu-west-2"
}

data "aws_connect_instance" "default" {
  instance_alias = "eastghats-dev"
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
  source        = "../../modules/amplify"
  app_name      = "custom-ccp"
  repo_url      = "https://github.com/support-eastghats/customccp.git"
  github_token  = var.github_token
  branch_name   = "dev"
  stage         = "DEVELOPMENT"
  domain_name   = "dev.ccp.eastghats.com"
  domain_prefix = ""

  environment_variables = {
    REACT_APP_REGION         = "eu-west-2"
    REACT_APP_CCP_URL        = local.connect_ccp_url
    REACT_APP_API_BASE_URL   = module.api_gateway.api_url
  }

  tags = {
    Project = "CustomCCP"
    Env     = "dev"
  }
}
