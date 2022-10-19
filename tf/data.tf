data "openstack_compute_flavor_v2" "small" {
  vcpus    = 1
  ram      = 2048
  min_disk = 15
}

data "openstack_images_image_v2" "img" {
  most_recent = true
  name        = var.image
}

data "openstack_networking_network_v2" "network" {
  external = false
}
