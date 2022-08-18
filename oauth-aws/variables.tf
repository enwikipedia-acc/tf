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

variable "oauth_instance_type_aws" {
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