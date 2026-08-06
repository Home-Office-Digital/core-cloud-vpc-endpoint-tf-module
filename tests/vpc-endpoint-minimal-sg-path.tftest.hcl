mock_provider "aws" {}

variables {
  vpc_id                      = "vpc-44444444444444444"
  vpc_endpoint_name           = "minimal-sg-endpoint"
  service_name                = "com.amazonaws.eu-west-2.ec2messages"
  subnet_ids                  = ["subnet-55555555555555555"]
  security_group_ids          = []
  managed_private_dns_enabled = false
  custom_private_r53_zone     = ""
  sg_description              = "Custom SG description for tests"
  sg_ingress_rules            = []
  sg_egress_rules             = []
  tags = {
    Name = "should-be-overwritten"
    Team = "platform"
  }
}

run "plan_minimal_sg_path" {
  command = plan

  assert {
    condition     = length(aws_security_group.this) == 1
    error_message = "Module should create a security group when security_group_ids is empty."
  }

  assert {
    condition     = aws_security_group.this[0].description == var.sg_description
    error_message = "Created security group should use sg_description input."
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress_rules) == 0
    error_message = "No ingress rules should be created when sg_ingress_rules is empty."
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.all_protocols) == 0
    error_message = "No all-protocol egress rules should be created when sg_egress_rules is empty."
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.with_ports) == 0
    error_message = "No port-based egress rules should be created when sg_egress_rules is empty."
  }

  assert {
    condition     = aws_vpc_endpoint.this.vpc_id == var.vpc_id
    error_message = "Endpoint VPC ID should match vpc_id input."
  }

  assert {
    condition     = aws_vpc_endpoint.this.service_name == var.service_name
    error_message = "Endpoint service_name should match input."
  }

  assert {
    condition     = length(aws_vpc_endpoint.this.security_group_ids) == 1
    error_message = "Endpoint should include one security group in minimal SG path."
  }

  assert {
    condition     = aws_vpc_endpoint.this.tags["Name"] == var.vpc_endpoint_name
    error_message = "Name tag should be enforced from vpc_endpoint_name even if tags.Name is set."
  }

  assert {
    condition     = aws_vpc_endpoint.this.tags["Team"] == var.tags["Team"]
    error_message = "Non-Name custom tags should be propagated to endpoint."
  }

  assert {
    condition     = length(aws_route53_zone.private) == 0
    error_message = "Custom Route53 zone should not be created when custom_private_r53_zone is empty."
  }

  assert {
    condition     = length(aws_route53_record.this) == 0
    error_message = "Custom Route53 record should not be created when custom_private_r53_zone is empty."
  }
}
