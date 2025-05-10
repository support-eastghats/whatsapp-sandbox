variable "region" {
  type        = string
  default     = "eu-west-2"
}

variable "api_gateway_id" {
  description = "API Gateway ID to allow invoke permissions"
  type        = string
}

variable "function_name" {
  type = string
}

variable "handler" {
  type    = string
  default = "index.handler"
}

variable "lambda_zip_path" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type = map(string)
}
