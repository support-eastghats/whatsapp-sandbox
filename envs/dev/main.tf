provider "aws" {
  region = "eu-west-2"
}

data "aws_connect_instance" "default" {
  instance_alias = "eastghats-dev"
}

locals {
  amplify_app_id = "d1b8m7s8f6rgmd"
  connect_ccp_url = "https://${data.aws_connect_instance.default.instance_alias}.my.connect.aws/ccp-v2/"
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

module "set_pause_resume_attr" {
  source           = "../../modules/lambda"
  function_name    = "setpauseresumeattr"
  handler          = "index.handler"
  lambda_zip_path  = "../../lambda-code/setpauseresumeattr.zip"
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

module "set_pause" {
  source           = "../../modules/lambda"
  function_name    = "setpause"
  handler          = "index.handler"
  lambda_zip_path  = "../../lambda-code/setpause.zip"
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

module "set_resume" {
  source           = "../../modules/lambda"
  function_name    = "setresume"
  handler          = "index.handler"
  lambda_zip_path  = "../../lambda-code/setresume.zip"
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
  stage_name = "$default"

  routes = {
    "/getRoutingProfiles"     = { method = "POST", lambda_uri = module.get_profiles_ccp.lambda_uri },
    "/updateRoutingProfiles"  = { method = "POST", lambda_uri = module.update_profiles_ccp.lambda_uri },
    "/setpauseresumeattr"     = { method = "put", lambda_uri = module.set_pause_resume_attr.lambda_uri },
    "/setpause"               = { method = "POST", lambda_uri = module.set_pause.lambda_uri },
    "/setresume"              = { method = "POST", lambda_uri = module.set_resume.lambda_uri }
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
  branch_name = "main"
  stage       = "PRODUCTION"

  environment_variables = {
    REACT_APP_ENV = "development"
    REACT_APP_DISPURL             = module.api_gateway.rest_api_url
    REACT_APP_APIKEY              = module.api_gateway.api_key_value
    REACT_APP_CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
    REACT_APP_CCPURL              = local.connect_ccp_url
    REACT_APP_REGION              = "eu-west-2"
    REACT_APP_LOGINURL            = "https://accounts.google.com/o/saml2/initsso?idpid=C00j5cpqj&spid=332463133108&forceauthn=false&authuser=0"
  }

  build_spec = file("${path.module}/buildspec.yml")

  tags = {
    Environment = "dev"
    Project     = "custom-ccp"
  }
}