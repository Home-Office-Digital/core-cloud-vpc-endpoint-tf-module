mock_provider "aws" {}

variables {
  vpc_id                             = "vpc-11111111111111111"
  vpc_endpoint_name                  = "custom-dns-endpoint"
  service_name                       = "com.amazonaws.eu-west-2.secretsmanager"
  security_group_ids                 = ["sg-1234567890abcdef0"]
  subnet_ids                         = ["subnet-11111111111111111", "subnet-22222222222222222"]
  managed_private_dns_enabled        = false
  custom_private_r53_zone            = "svc.internal.example"
  custom_private_r53_associated_vpcs = ["vpc-22222222222222222"]
  sg_ingress_rules                   = []
  sg_egress_rules                    = []
}

run "plan_custom_dns_path" {
  command = plan

  assert {
    condition     = length(aws_security_group.this) == 0
    error_message = "Module should not create a security group when security_group_ids are provided."
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress_rules) == 0
    error_message = "Ingress rules should not be created when using existing security groups."
  }

  assert {
    condition     = length(aws_route53_zone.private) == 1
    error_message = "A private Route53 zone should be created when custom_private_r53_zone is set."
  }

  assert {
    condition     = length(aws_route53_record.this) == 1
    error_message = "An alias record should be created for the custom private zone."
  }

  assert {
    condition     = aws_route53_zone.private[0].name == var.custom_private_r53_zone
    error_message = "The created Route53 zone name should match custom_private_r53_zone."
  }

  assert {
    condition     = aws_route53_record.this[0].type == "A"
    error_message = "Custom DNS record should be type A alias."
  }

  assert {
    condition     = contains(aws_vpc_endpoint.this.security_group_ids, var.security_group_ids[0])
    error_message = "The provided security group should be attached to the endpoint."
  }

  assert {
    condition     = aws_vpc_endpoint.this.tags["Name"] == var.vpc_endpoint_name
    error_message = "Endpoint Name tag should match vpc_endpoint_name."
  }

  assert {
    condition     = aws_vpc_endpoint.this.private_dns_enabled == false
    error_message = "Managed private DNS should be disabled in this custom DNS scenario."
  }
}
