variable "app_name" {
  description = "Amplify app name"
  type        = string
}

variable "repo_url" {
  description = "GitHub repo HTTPS URL"
  type        = string
}

variable "github_token" {
  description = "GitHub token for Amplify integration"
  type        = string
  sensitive   = true
}

variable "existing_app_id" {
  description = "Existing Amplify app ID to update"
  type        = string
}

variable "branch_name" {
  description = "Branch to auto-deploy from"
  type        = string
}

variable "stage" {
  description = "Deployment stage (DEVELOPMENT, PRODUCTION)"
  type        = string
  default     = "DEVELOPMENT"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Amplify environment variables"
}

variable "domain_name" {
  type        = string
  default     = null
  description = "Custom domain (optional)"
}

variable "domain_prefix" {
  type        = string
  default     = ""
  description = "Prefix for subdomain (e.g., dev)"
}

variable "tags" {
  type        = map(string)
  default     = {}
}


resource "aws_amplify_app_environment_variables" "update_env" {
  app_id = var.existing_app_id

  environment_variables = var.environment_variables
}
