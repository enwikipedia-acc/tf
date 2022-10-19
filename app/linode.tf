data "linode_domain" "aws" {
  count = var.linode_dns ? 1 : 0

  domain = var.linode_dns_zone
}

resource "linode_domain_record" "lb" {
  count = var.linode_dns ? 1 : 0

  domain_id   = data.linode_domain.aws[0].id
  name        = var.linode_dns_name
  record_type = "CNAME"
  target      = var.use_lb ? module.loadbalancer[0].lb_hostname : aws_instance.app.public_dns
}

resource "linode_domain_record" "app-server" {
  count = var.linode_dns ? 1 : 0

  domain_id   = data.linode_domain.aws[0].id
  name        = "${var.linode_dns_name}-host"
  record_type = "CNAME"
  target      = aws_instance.app.public_dns
}

resource "linode_domain_record" "db-server" {
  count = var.linode_dns ? 1 : 0

  domain_id   = data.linode_domain.aws[0].id
  name        = "${var.linode_dns_name}-db"
  record_type = "CNAME"
  target      = aws_instance.db.private_dns
}
