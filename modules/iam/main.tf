data "aws_iam_role" "existing" {
  name  = var.role_name
  count = var.force_create ? 0 : 1
}

resource "aws_iam_role" "lambda_exec_role" {
  count = var.force_create ? 1 : 0

  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [ {
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  count = var.force_create ? 1 : 0

  name = "${var.role_name}-inline-policy"
  role = aws_iam_role.lambda_exec_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*",
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}
