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
  tenant_name = "account-creation-assistance"
  region      = "eqiad1-r"
  auth_url    = "http://openstack.eqiad1.wikimediacloud.org:5000/v3"
}


output "test" {
  value = data.openstack_blockstorage_volume_v3.application
}