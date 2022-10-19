terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    linode = {
      source  = "linode/linode"
      version = "~> 1.29.1"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      "Terraform"   = "yes"
      "Project"     = var.project
      "Module"      = "app"
      "Environment" = var.environment
    }
  }
}

provider "linode" {}
