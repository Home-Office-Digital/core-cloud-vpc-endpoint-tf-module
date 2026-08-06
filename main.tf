resource "aws_vpc_endpoint" "this" {
  vpc_id            = var.vpc_id
  service_name      = var.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = length(var.security_group_ids) != 0 ? var.security_group_ids : [aws_security_group.this[0].id]
  subnet_ids          = var.subnet_ids
  private_dns_enabled = var.managed_private_dns_enabled

  tags = merge(
    var.tags,
    {
      "Name" = var.vpc_endpoint_name
    }
  )
}

resource "aws_route53_zone" "private" {
  count = !var.managed_private_dns_enabled && var.custom_private_r53_zone != "" ? 1 : 0

  name = var.custom_private_r53_zone

  dynamic "vpc" {
    for_each = toset(concat([var.vpc_id], var.custom_private_r53_associated_vpcs))
    content {
      vpc_id = vpc.key
    }
  }

  tags = merge(
    var.tags,
    {
      "vpce_name" = var.vpc_endpoint_name
      "vpce_id"   = aws_vpc_endpoint.this.id
    }
  )
}

resource "aws_route53_record" "this" {
  count   = !var.managed_private_dns_enabled && var.custom_private_r53_zone != "" ? 1 : 0
  zone_id = aws_route53_zone.private[0].zone_id
  name    = var.custom_private_r53_zone
  type    = "A"

  alias {
    name                   = "${aws_vpc_endpoint.this.dns_entry[0]["dns_name"]}."
    zone_id                = aws_vpc_endpoint.this.dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }
}

#checkov:skip=CKV2_AWS_5: Security group is conditionally attached to aws_vpc_endpoint.this via security_group_ids.
resource "aws_security_group" "this" {
  count       = length(var.security_group_ids) == 0 ? 1 : 0
  name        = "${var.vpc_endpoint_name}-sg"
  description = var.sg_description
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  count             = length(var.security_group_ids) == 0 ? length(var.sg_ingress_rules) : 0
  security_group_id = aws_security_group.this[0].id
  description       = var.sg_ingress_rules[count.index].description
  from_port         = var.sg_ingress_rules[count.index].from_port
  to_port           = var.sg_ingress_rules[count.index].to_port
  ip_protocol       = var.sg_ingress_rules[count.index].ip_protocol
  cidr_ipv4         = var.sg_ingress_rules[count.index].cidr_ipv4

}

resource "aws_vpc_security_group_egress_rule" "all_protocols" {
  for_each = {
    for k, rule in var.sg_egress_rules :
    k => rule if rule.ip_protocol == "-1"
  }

  security_group_id = aws_security_group.this[0].id
  description       = lookup(each.value, "description", null)
  ip_protocol       = "-1"
  cidr_ipv4         = each.value.cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "with_ports" {
  for_each = {
    for k, rule in var.sg_egress_rules :
    k => rule if rule.ip_protocol != "-1"
  }

  security_group_id = aws_security_group.this[0].id
  description       = lookup(each.value, "description", null)
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}
