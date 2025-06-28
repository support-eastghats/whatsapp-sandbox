data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "lambda_func" {
  function_name    = var.function_name
  filename         = var.lambda_zip_path
  handler          = var.handler
  runtime          = "nodejs18.x"
  role             = var.lambda_role_arn
  timeout          = 60
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  layers           = [var.lambda_layer_arn]

  environment {
    variables = var.env_vars
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_func.function_name}"
  retention_in_days = 14
}
