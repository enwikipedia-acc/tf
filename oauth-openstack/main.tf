terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }

    cloudvps = {
      source  = "terraform.wmcloud.org/registry/cloudvps"
      version = "~> 0.1.1"
    }
  }

  required_version = ">= 1.3.0"
}

provider "openstack" {
  tenant_name                   = var.project
  auth_url                      = "https://openstack.eqiad1.wikimediacloud.org:25000/v3"
  application_credential_id     = var.application_credential_id
  application_credential_secret = var.application_credential_secret

}

provider "cloudvps" {
  os_auth_url                      = "https://openstack.eqiad1.wikimediacloud.org:25000/v3"
  os_project_id                    = var.project
  os_application_credential_id     = var.application_credential_id
  os_application_credential_secret = var.application_credential_secret
}

resource "openstack_blockstorage_volume_v3" "oauth-www" {
  name        = "${var.resource_prefix}-oauth-wiki"
  description = "OAuth MediaWiki app; Managed by Terraform"
  size        = 2
}

resource "openstack_blockstorage_volume_v3" "oauth-db" {
  name        = "${var.resource_prefix}-oauth-db2"
  description = "OAuth MediaWiki database; Managed by Terraform"
  size        = 2
}

resource "openstack_compute_instance_v2" "oauthapp" {
  name      = "${var.resource_prefix}-${var.instance_name}"
  image_id  = data.openstack_images_image_v2.img.id
  flavor_id = data.openstack_compute_flavor_v2.small.id
  user_data = file("${path.module}/../userdata/oauth/userdata.sh")

  security_groups = [
    openstack_networking_secgroup_v2.web.name
  ]

  metadata = {
    publicdns = "${var.resource_prefix}-${var.proxy_name}.${var.proxy_domain}"
    terraform = "Yes"
  }

  network {
    uuid = data.openstack_networking_network_v2.network.id
  }

  lifecycle {
    ignore_changes = [ image_id ]
  }
}

resource "openstack_compute_volume_attach_v2" "oauth-www" {
  instance_id = openstack_compute_instance_v2.oauthapp.id
  volume_id   = openstack_blockstorage_volume_v3.oauth-www.id
}

resource "openstack_compute_volume_attach_v2" "oauth-db" {
  instance_id = openstack_compute_instance_v2.oauthapp.id
  volume_id   = openstack_blockstorage_volume_v3.oauth-db.id
}

resource "cloudvps_web_proxy" "oauth_proxy" {
  hostname = local.proxy_hostname
  domain   = var.proxy_domain
  backends = ["http://${openstack_compute_instance_v2.oauthapp.access_ip_v4}:80"]
}
