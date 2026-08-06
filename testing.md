# Terraform Testing

This module includes local Terraform tests under `tests/` using the native Terraform test framework.

## What These Tests Validate

- Default path behavior: the module creates its own security group and associated rules when `security_group_ids` is empty.
- Custom DNS path behavior: custom Route53 resources are planned when `custom_private_r53_zone` is provided.
- Managed private DNS behavior: custom Route53 resources are skipped when `managed_private_dns_enabled` is true.
- Basic resource wiring: endpoint type, selected security groups, and tags.

## Why This Is Safe

- Tests use `mock_provider "aws" {}` to avoid real provider API calls.
- Test runs use `command = plan` only, so no infrastructure is applied.
- Inputs use placeholder values and RFC 5737 documentation CIDRs.

## Prerequisites

- Terraform CLI `>= 1.6` (Terraform test support)

## Run Tests Locally

From the module root:

```bash
terraform init
terraform test
```

Run a single test file:

```bash
terraform test tests/vpc-endpoint-default-path.tftest.hcl
terraform test tests/vpc-endpoint-custom-dns.tftest.hcl
terraform test tests/vpc-endpoint-managed-private-dns.tftest.hcl
```

## Notes

- These tests are intentionally plan-focused and do not validate apply-time values returned by AWS.
- Add additional `.tftest.hcl` files in `tests/` as module behavior grows.
