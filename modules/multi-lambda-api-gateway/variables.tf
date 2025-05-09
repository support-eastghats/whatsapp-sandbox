variable "name" {
  type        = string
  description = "Name of the API Gateway"
}

variable "stage_name" {
  type        = string
  description = "Name of the deployment stage (e.g., dev, prod)"
}

variable "region" {
  type        = string
  description = "AWS region for deployment"
  default     = "eu-west-2"
}

variable "routes" {
  type = map(object({
    method     = string
    path       = string
    lambda_uri = string
  }))
  description = "Map of route paths and Lambda URIs"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}
