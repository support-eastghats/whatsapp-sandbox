output "lambda_uri" {
  value = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_func.arn}/invocations"
}


output "lambda_name" {
  value = aws_lambda_function.lambda_func.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.lambda_func.arn
}
