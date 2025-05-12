# envs/dev/main.tf

provider "aws" {
  region = "eu-west-2"
}

# data "aws_connect_instance" "default" {
#   instance_alias = "eastghats-dev"
# }

# locals {
#   amplify_app_id  = "d1b8m7s8f6rgmd"
#   connect_ccp_url = "https://${data.aws_connect_instance.default.instance_alias}.my.connect.aws/ccp-v2/"
# }

# variable "github_token" {
#   description = "GitHub Token for Amplify app"
#   type        = string
#   sensitive   = true
#   default     = ""
# }

# module "iam" {
#   source       = "../../modules/iam"
#   role_name    = "eastghats-ccp-lambda-role-dev"
#   force_create = true

#   tags = {
#     Project     = "eastghats-ccp"
#     Environment = "dev"
#   }
# }

# module "get_available_profiles" {
#   source           = "../../modules/lambda"
#   function_name    = "getAvailableRoutingProfiles"
#   handler          = "index.handler"
#   lambda_zip_path  = "../../lambda-code/getAvailableRoutingProfiles.zip"
#   lambda_role_arn  = module.iam.lambda_exec_role_arn
#   api_gateway_id   = module.api_gateway.api_id
#   api_gateway_execution_arn = module.api_gateway.execution_arn
#   env_vars = {
#     STAGE               = "dev"
#     CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
#   }
#   tags = {
#     Project     = "eastghats-ccp"
#     Environment = "dev"
#   }
# }

# resource "aws_lambda_permission" "get_available_profiles_permission" {
#   statement_id  = "AllowAPIGatewayInvokeGetAvailableProfiles"
#   action        = "lambda:InvokeFunction"
#   function_name = module.get_available_profiles.lambda_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${module.api_gateway.execution_arn}/*/*"
# }

# module "switch_routing_profile" {
#   source           = "../../modules/lambda"
#   function_name    = "switchRoutingProfile"
#   handler          = "index.handler"
#   lambda_zip_path  = "../../lambda-code/switchRoutingProfile.zip"
#   lambda_role_arn  = module.iam.lambda_exec_role_arn
#   api_gateway_id   = module.api_gateway.api_id
#   api_gateway_execution_arn = module.api_gateway.execution_arn
#   env_vars = {
#     STAGE               = "dev"
#     CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
#   }
#   tags = {
#     Project     = "eastghats-ccp"
#     Environment = "dev"
#   }
# }

# resource "aws_lambda_permission" "switch_routing_profile_permission" {
#   statement_id  = "AllowAPIGatewayInvokeSwitchRoutingProfile"
#   action        = "lambda:InvokeFunction"
#   function_name = module.switch_routing_profile.lambda_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${module.api_gateway.execution_arn}/*/*"
# }

# module "set_pause_resume_attr" {
#   source           = "../../modules/lambda"
#   function_name    = "setpauseresumeattr"
#   handler          = "index.handler"
#   lambda_zip_path  = "../../lambda-code/setpauseresumeatt.zip"
#   lambda_role_arn  = module.iam.lambda_exec_role_arn
#   api_gateway_id   = module.api_gateway.api_id
#   api_gateway_execution_arn = module.api_gateway.execution_arn
#   env_vars = {
#     STAGE               = "dev"
#     CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
#   }
#   tags = {
#     Project     = "eastghats-ccp"
#     Environment = "dev"
#   }
# }

# resource "aws_lambda_permission" "set_pause_resume_attr_permission" {
#   statement_id  = "AllowAPIGatewayInvokeSetPauseResumeAttr"
#   action        = "lambda:InvokeFunction"
#   function_name = module.set_pause_resume_attr.lambda_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${module.api_gateway.execution_arn}/*/*"
# }

# module "set_pause" {
#   source           = "../../modules/lambda"
#   function_name    = "setpause"
#   handler          = "index.handler"
#   lambda_zip_path  = "../../lambda-code/setpause.zip"
#   lambda_role_arn  = module.iam.lambda_exec_role_arn
#   api_gateway_id   = module.api_gateway.api_id
#   api_gateway_execution_arn = module.api_gateway.execution_arn
#   env_vars = {
#     STAGE               = "dev"
#     CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
#   }
#   tags = {
#     Project     = "eastghats-ccp"
#     Environment = "dev"
#   }
# }

# resource "aws_lambda_permission" "setpause_permission" {
#   statement_id  = "AllowAPIGatewayInvokeSetPause"
#   action        = "lambda:InvokeFunction"
#   function_name = module.set_pause.lambda_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${module.api_gateway.execution_arn}/*/*"
# }

# module "set_resume" {
#   source           = "../../modules/lambda"
#   function_name    = "setresume"
#   handler          = "index.handler"
#   lambda_zip_path  = "../../lambda-code/setresume.zip"
#   lambda_role_arn  = module.iam.lambda_exec_role_arn
#   api_gateway_id   = module.api_gateway.api_id
#   api_gateway_execution_arn = module.api_gateway.execution_arn
#   env_vars = {
#     STAGE               = "dev"
#     CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
#   }
#   tags = {
#     Project     = "eastghats-ccp"
#     Environment = "dev"
#   }
# }

# resource "aws_lambda_permission" "setresume_permission" {
#   statement_id  = "AllowAPIGatewayInvokeSetResume"
#   action        = "lambda:InvokeFunction"
#   function_name = module.set_resume.lambda_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${module.api_gateway.execution_arn}/*/*"
# }

# module "api_gateway" {
#   source     = "../../modules/multi-lambda-api-gateway"
#   name       = "eastghats-ccp-api-dev"
#   stage_name = "dev"

#   routes = {
#     "getAvailableRoutingProfiles"     = { path = "/getAvailableRoutingProfiles", method = "POST", lambda_uri = module.get_available_profiles.lambda_uri },
#     "switchRoutingProfile"            = { path = "/switchRoutingProfile", method = "POST", lambda_uri = module.switch_routing_profile.lambda_uri },
#     "setpauseresumeattr"              = { path = "/setpauseresumeattr", method = "PUT",  lambda_uri = module.set_pause_resume_attr.lambda_uri },
#     "setpause"                        = { path = "/setpause", method = "POST", lambda_uri = module.set_pause.lambda_uri },
#     "setresume"                       = { path = "/setresume", method = "POST", lambda_uri = module.set_resume.lambda_uri }
#   }

#   tags = {
#     Project     = "eastghats-ccp"
#     Environment = "dev"
#   }
# }

# module "amplify_app" {
#   source        = "../../modules/amplify"
#   app_name      = "customccp-ui"
#   repo_url      = "https://github.com/support-eastghats/customccp-ui"
#   github_token  = var.github_token
#   branch_name   = "main"
#   stage         = "PRODUCTION"

#   environment_variables = {
#     REACT_APP_ENV                 = "development"
#     REACT_APP_DISPURL             = module.api_gateway.rest_api_url
#     REACT_APP_APIKEY              = module.api_gateway.api_key_value
#     REACT_APP_CONNECT_INSTANCE_ID = data.aws_connect_instance.default.id
#     REACT_APP_CCPURL              = local.connect_ccp_url
#     REACT_APP_REGION              = "eu-west-2"
#     REACT_APP_LOGINURL            = "https://accounts.google.com/o/saml2/initsso?idpid=C00j5cpqj&spid=332463133108&forceauthn=false&authuser=0"
#   }

#   build_spec = file("${path.module}/buildspec.yml")

#   tags = {
#     Environment = "dev"
#     Project     = "custom-ccp"
#   }
# }

