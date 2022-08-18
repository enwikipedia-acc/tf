terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.48.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "openstack" {
  tenant_name = var.project
  region      = "eqiad1-r"
  auth_url    = "http://openstack.eqiad1.wikimediacloud.org:5000/v3"
}
