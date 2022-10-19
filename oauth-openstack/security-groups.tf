resource "openstack_networking_secgroup_v2" "web" {
  name        = "${var.resource_prefix}-oauth-web"
  description = "Managed by Terraform; OAuth test application"
}

resource "openstack_networking_secgroup_rule_v2" "v4-http" {
  direction        = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 80
  port_range_max   = 80
  remote_ip_prefix = "0.0.0.0/0"
  description      = "HTTP inbound; Managed by Terraform"

  security_group_id = openstack_networking_secgroup_v2.web.id
}

resource "openstack_networking_secgroup_rule_v2" "v6-http" {
  direction        = "ingress"
  ethertype        = "IPv6"
  protocol         = "tcp"
  port_range_min   = 80
  port_range_max   = 80
  remote_ip_prefix = "::/0"
  description      = "HTTP inbound; Managed by Terraform"

  security_group_id = openstack_networking_secgroup_v2.web.id
}

