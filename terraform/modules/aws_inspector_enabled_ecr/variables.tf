variable "ecr_repo_name" {
  type = string
}

variable "ecr_role_name" {
  type        = string
  description = "name of iam role to attach access to ecr repo and scan findings"
}
