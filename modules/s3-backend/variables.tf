variable "bucket_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "force_create" {
  description = "Set to true to create the bucket (false = use existing)"
  type        = bool
  default     = false
}
