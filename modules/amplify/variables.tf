variable "app_name" {
  type = string
}

variable "repo_url" {
  type = string
}

variable "github_token" {
  type = string
  sensitive = true
}

variable "branch_name" {
  type = string
}

variable "stage" {
  type = string
}

variable "environment_variables" {
  type = map(string)
  default = {}
}

variable "build_spec" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {}
}
