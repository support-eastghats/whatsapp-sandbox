
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
