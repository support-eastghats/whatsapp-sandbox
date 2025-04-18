
output "lambda_uri" {
  value = aws_lambda_function.lambda_func.invoke_arn
}

output "lambda_name" {
  value = aws_lambda_function.lambda_func.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.lambda_func.arn
}
