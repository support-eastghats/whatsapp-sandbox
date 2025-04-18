provider "aws" {
  region = "ap-south-1"
}

module "iam" {
  source        = "../../modules/iam"
  role_name     = "goatfarm-lambda-role-prod"
  force_create  = false
  tags = {
    Project     = "goatfarm"
    Environment = "prod"
  }
}


module "lambda_test" {
  source           = "../../modules/lambda"
  function_name    = "lambdaprodtest"
  handler          = "index.handler"
  lambda_zip_path  = "../../lambda-code/lambda_test.zip"
  lambda_role_arn  = module.iam.lambda_exec_role_arn
  env_vars         = { STAGE = "prod" }
  tags             = { Project = "goatfarm", Environment = "prod" }
}


module "api_gateway" {
  source = "../../modules/multi-lambda-api-gateway"
  name   = "goatfarm-api-prod"
  routes = {
    "/test"        = { method = "POST", lambda_uri = module.lambda_test.lambda_uri },
  }

  tags = {
    Project     = "goatfarm"
    Environment = "prod"
  }
}


module "goatfarm_data_bucket" {
  source        = "../../modules/s3-backend"
  bucket_name   = "goatfarm-data-prod-backend"
  force_create  = false  # <-- Do not recreate
  tags = {
    Project     = "goatfarm"
    Environment = "prod"
  }
}