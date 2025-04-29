output "app_id" {
  value = aws_amplify_app.this[0].id
}

output "app_name" {
  value = aws_amplify_app.this[0].name
}

output "app_url" {
  value = aws_amplify_app.this[0].default_domain
}
