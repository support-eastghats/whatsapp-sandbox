output "lambda_exec_role_arn" {
  description = "ARN of the Lambda execution role"
  value = var.force_create ? aws_iam_role.lambda_exec_role[0].arn : data.aws_iam_role.existing[0].arn
}
