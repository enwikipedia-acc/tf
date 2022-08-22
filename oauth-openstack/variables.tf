variable "project" {
  type    = string
  default = "account-creation-assistance"
}

variable "image" {
  type    = string
  default = "debian-11.0-bullseye"
}

variable "publicdns" {
  type    = string
  default = "accounts-oauth.wmflabs.org"
}
