data "linode_domain" "aws" {
  count = var.linode_dns ? 1 : 0

  domain = var.linode_dns_zone
}

resource "linode_domain_record" "oauth" {
  count = var.linode_dns ? 1 : 0

  domain_id   = data.linode_domain.aws[0].id
  name        = var.linode_dns_name
  record_type = "CNAME"
  target      = aws_instance.oauth.public_dns
}
