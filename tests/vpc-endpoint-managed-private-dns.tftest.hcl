mock_provider "aws" {}

variables {
  vpc_id                      = "vpc-33333333333333333"
  vpc_endpoint_name           = "managed-private-dns-endpoint"
  service_name                = "com.amazonaws.eu-west-2.ssm"
  security_group_ids          = ["sg-fedcba09876543210"]
  subnet_ids                  = ["subnet-33333333333333333", "subnet-44444444444444444"]
  managed_private_dns_enabled = true
  custom_private_r53_zone     = "managed.internal.example"
  sg_ingress_rules            = []
  sg_egress_rules             = []
  tags = {
    Environment = "test"
    Owner       = "terraform-test"
  }
}

run "plan_managed_private_dns_path" {
  command = plan

  assert {
    condition     = aws_vpc_endpoint.this.private_dns_enabled == true
    error_message = "Managed private DNS should be enabled when managed_private_dns_enabled is true."
  }

  assert {
    condition     = length(aws_route53_zone.private) == 0
    error_message = "Custom Route53 zone should not be created when managed private DNS is enabled."
  }

  assert {
    condition     = length(aws_route53_record.this) == 0
    error_message = "Custom Route53 record should not be created when managed private DNS is enabled."
  }

  assert {
    condition     = length(aws_security_group.this) == 0
    error_message = "Module security group should not be created when security_group_ids are provided."
  }

  assert {
    condition     = contains(aws_vpc_endpoint.this.security_group_ids, var.security_group_ids[0])
    error_message = "Provided security group should be attached to endpoint."
  }

  assert {
    condition     = aws_vpc_endpoint.this.tags["Environment"] == var.tags["Environment"]
    error_message = "Custom tags should be propagated to endpoint."
  }

  assert {
    condition     = aws_vpc_endpoint.this.tags["Name"] == var.vpc_endpoint_name
    error_message = "Name tag should still be set from vpc_endpoint_name."
  }
}
