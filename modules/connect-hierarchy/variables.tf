variable "instance_id" {
  type        = string
  description = "Amazon Connect Instance ID"
}

variable "projects" {
  type = map(object({
    groups = map(object({
      roles = list(string)
    }))
  }))
}
