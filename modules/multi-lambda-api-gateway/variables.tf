
variable "name" {
  type        = string
  description = "API Gateway name"
}

variable "routes" {
  type = map(object({
    method     = string
    lambda_uri = string
  }))
  description = "Map of route paths and Lambda URIs"
}

variable "tags" {
  type        = map(string)
}

variable "cors" {
  description = "CORS configuration for API Gateway"
  type = object({
    allow_headers     = list(string)
    allow_methods     = list(string)
    allow_origins     = list(string)
    allow_credentials = bool
    expose_headers    = list(string)
    max_age           = number
  })
  default = {
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    allow_credentials = false
    expose_headers    = ["*"]
    max_age           = 86400
  }
}
