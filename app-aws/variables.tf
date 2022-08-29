variable "linode_dns" {
  type     = bool
  default  = false
  nullable = false
}

variable "linode_dns_name" {
  type    = string
  default = "oauth"
}

variable "linode_dns_zone" {
  type    = string
  default = "aws.stwalkerster.net"
}

variable "app_instance_type_aws" {
  type    = string
  default = "t2.micro"
}

variable "db_instance_type_aws" {
  type    = string
  default = "t2.small"
}

variable "key_pair_name" {
  type    = string
  default = "simon@stwalkerster.co.uk (April 2013)"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "project" {
  type    = string
  default = "account-creation-assistance"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "use_lb" {
  type = bool
  default = false
}

variable "https" {
  type = bool
  default = false
}

variable "snapshot_www" {
  type = string
  default = ""
}

variable "snapshot_db" {
  type = string
  default = ""
}

variable "snapshot_dbbackup" {
  type = string
  default = ""
}

locals {
  urlscheme = var.https ? "https://" : "http://"
  hostname = var.linode_dns ? "${var.linode_dns_name}.${var.linode_dns_zone}" :aws_instance.app.public_dns
}

output "dns" {
  value = "${local.urlscheme}${local.hostname}/internal.php"
  description = "Application instance:"
}
