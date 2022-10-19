variable "application_credential_id" {
  type = string
}

variable "application_credential_secret" {
  type      = string
  sensitive = true
}

variable "project" {
  type    = string
  default = "account-creation-assistance"
}

variable "image" {
  type    = string
  default = "debian-11.0-bullseye"
}

variable "resource_prefix" {
  type    = string
  default = "accounts"
}

variable "instance_name" {
  type    = string
  default = "mwoauth"
}

variable "proxy_name" {
  type    = string
  default = "oauth"
}

variable "proxy_domain" {
  type    = string
  default = "wmcloud.org"
}

locals {
  proxy_hostname = "${var.resource_prefix}-${var.proxy_name}"
}
