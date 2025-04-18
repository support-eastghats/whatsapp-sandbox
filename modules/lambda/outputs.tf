
output "lambda_uri" {
  value = aws_lambda_function.lambda_func.invoke_arn
}
