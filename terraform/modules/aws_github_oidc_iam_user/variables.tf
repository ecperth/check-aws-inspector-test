variable "thumbprint_list" {
  type        = list(string)
  description = "set of openid thumbprints of the allowed host"
}

variable "allowed_subs" {
  type        = list(string)
  description = "the github resources which can auth as this user"
}
