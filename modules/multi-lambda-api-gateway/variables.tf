
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
