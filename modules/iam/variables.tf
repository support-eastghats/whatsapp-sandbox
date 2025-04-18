variable "role_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "force_create" {
  description = "Set to true to force creating a new IAM role (only if not already exists)"
  type        = bool
  default     = false
}