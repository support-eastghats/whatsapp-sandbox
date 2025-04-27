resource "aws_amplify_app" "this" {
  name         = var.app_name
  repository   = var.repo_url
  platform     = "WEB"
  oauth_token  = var.github_token

  environment_variables = var.environment_variables

  build_spec = var.build_spec_path != null ? file(var.build_spec_path) : null

  custom_rule {
    source = "/<*>"
    target = "/index.html"
    status = "200"
  }

  tags = var.tags
}

resource "aws_amplify_branch" "main_branch" {
  app_id            = aws_amplify_app.this.id
  branch_name       = var.branch_name
  stage             = var.stage
  framework         = "React"
  enable_auto_build = true
}

resource "aws_amplify_domain_association" "domain" {
  count       = var.domain_name != null ? 1 : 0
  app_id      = aws_amplify_app.this.id
  domain_name = var.domain_name

  sub_domain {
    branch_name = var.branch_name
    prefix      = var.domain_prefix
  }
}
