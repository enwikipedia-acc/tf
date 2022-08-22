terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
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


data "openstack_compute_flavor_v2" "small" {
  vcpus    = 1
  ram      = 2048
  min_disk = 15
}

data "openstack_images_image_v2" "img" {
  most_recent = true
  name = var.image
}

data "openstack_blockstorage_volume_v3" "oauth-www" {
  name = "oauth-www"
}

data "openstack_blockstorage_volume_v3" "oauth-db" {
  name = "oauth-db"
}


resource "openstack_compute_instance_v2" "oauthapp" {
  name            = "accounts-mwoauth"
  image_id        = data.openstack_images_image_v2.img.id
  flavor_id       = data.openstack_compute_flavor_v2.small.id
  security_groups = [openstack_networking_secgroup_v2.web.name]

  metadata = {
    publicdns = var.publicdns
  }

  user_data = file("${path.module}/../userdata/oauth/userdata.sh")

}

resource "openstack_compute_volume_attach_v2" "oauth-www" {
  instance_id = openstack_compute_instance_v2.oauthapp.id
  volume_id   = data.openstack_blockstorage_volume_v3.oauth-www.id
}

resource "openstack_compute_volume_attach_v2" "oauth-db" {
  instance_id = openstack_compute_instance_v2.oauthapp.id
  volume_id   = data.openstack_blockstorage_volume_v3.oauth-db.id
}
