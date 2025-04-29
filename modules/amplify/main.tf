resource "aws_amplify_app" "this" {
  name        = var.app_name
  repository  = var.repo_url
  platform    = "WEB"
  oauth_token = var.github_token

  environment_variables = var.environment_variables

  build_spec = var.build_spec

  custom_rule {
    source = "/<*>"
    target = "/index.html"
    status = "404-200"
  }

  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|ttf|map|json)$)([^.]+$)/>"
    target = "/index.html"
    status = "200"
  }

  tags = var.tags
}

resource "aws_amplify_branch" "this" {
  app_id            = aws_amplify_app.this.id
  branch_name       = var.branch_name
  stage             = var.stage
  framework         = "React"
  enable_auto_build = true
}
