variable "name" {
  type        = string
  description = "API Gateway name"
}

variable "routes" {
  type = map(object({
    method     = string
    path       = string
    lambda_uri = string
  }))
  description = "Map of route configurations"
}

variable "tags" {
  type = map(string)
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "stage_name" {
  type        = string
  description = "Name of the API Gateway stage"
  default     = "$default"
}
