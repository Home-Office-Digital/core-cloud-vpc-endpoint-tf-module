mock_provider "aws" {}

variables {
  vpc_id            = "vpc-00000000000000000"
  vpc_endpoint_name = "example-service"
  service_name      = "com.amazonaws.eu-west-2.execute-api"
  subnet_ids        = ["subnet-00000000000000001", "subnet-00000000000000002"]
  sg_ingress_rules = [
    {
      description = "Allow HTTPS from documentation network"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "198.51.100.0/24"
    }
  ]
  sg_egress_rules = [
    {
      description = "Allow all egress"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS egress"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "203.0.113.0/24"
    }
  ]
}

run "plan_default_path" {
  command = plan

  assert {
    condition     = aws_vpc_endpoint.this.vpc_endpoint_type == "Interface"
    error_message = "VPC endpoint type should be Interface."
  }

  assert {
    condition     = length(aws_security_group.this) == 1
    error_message = "Module should create a security group when security_group_ids is empty."
  }

  assert {
    condition     = length(aws_vpc_endpoint.this.security_group_ids) == 1
    error_message = "Endpoint should have exactly one security group in the default path."
  }

  assert {
    condition     = alltrue([for subnet_id in var.subnet_ids : contains(aws_vpc_endpoint.this.subnet_ids, subnet_id)])
    error_message = "All provided subnet IDs should be wired to the endpoint."
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress_rules) == 1
    error_message = "Expected one ingress rule from sg_ingress_rules input."
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.all_protocols) == 1
    error_message = "Expected one all-protocol egress rule."
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.with_ports) == 1
    error_message = "Expected one port-based egress rule."
  }

  assert {
    condition     = length(aws_route53_zone.private) == 0
    error_message = "Custom Route53 resources should not be created when custom_private_r53_zone is empty."
  }

  assert {
    condition     = aws_vpc_endpoint.this.private_dns_enabled == false
    error_message = "Managed private DNS should be disabled in this scenario."
  }

  assert {
    condition     = aws_vpc_endpoint.this.tags["Name"] == var.vpc_endpoint_name
    error_message = "Endpoint Name tag should match vpc_endpoint_name."
  }
}
