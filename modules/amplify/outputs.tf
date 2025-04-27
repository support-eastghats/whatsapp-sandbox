output "app_id" {
  value = aws_amplify_app.this.id
}

output "app_name" {
  value = aws_amplify_app.this.name
}

output "app_url" {
  value = aws_amplify_app.this.default_domain
}
