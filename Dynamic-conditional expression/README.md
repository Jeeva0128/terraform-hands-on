# Terraform Hands-on: Dynamic Blocks and Conditional Configuration

This exercise creates an AWS security group whose ingress rules are generated
from a variable. It demonstrates Terraform's `dynamic` block syntax and a
`for_each` expression for producing one nested `ingress` block per rule.

## Objectives

- Define a typed list of ingress-rule objects.
- Generate repeated security-group ingress blocks with `dynamic`.
- Read values from the current `dynamic` block with `ingress.value`.
- Query the VPCs available in the configured AWS region.
- Expose security-group and VPC information through Terraform outputs.
- Validate the configuration before creating AWS resources.

## Files

| File | Purpose |
| --- | --- |
| [`main.tf`](./main.tf) | Declares the security group and its dynamic ingress blocks. |
| [`variables.tf`](./variables.tf) | Defines the typed `ingress_rules` input variable. |
| [`terraform.tfvars`](./terraform.tfvars) | Supplies SSH, HTTP, and HTTPS ingress rules. |
| [`data.tf`](./data.tf) | Lists VPCs and exposes their CIDR, default status, and tags. |
| [`outputs.tf`](./outputs.tf) | Outputs the security-group ID and name. |
| [`provider.tf`](./provider.tf) | Configures the AWS region and CLI profile. |
| [`version.tf`](./version.tf) | Constrains Terraform and the AWS provider versions. |
| [`.terraform.lock.hcl`](./.terraform.lock.hcl) | Records the selected provider version and checksums. |

## Dynamic ingress block

The variable is a list of objects, so every list element represents one
security-group rule:

```hcl
variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
```

The resource uses the list with a `dynamic` block:

```hcl
dynamic "ingress" {
  for_each = var.ingress_rules

  content {
    from_port   = ingress.value.from_port
    to_port     = ingress.value.to_port
    protocol    = ingress.value.protocol
    cidr_blocks = ingress.value.cidr_blocks
  }
}
```

Terraform creates one `ingress` block for each element of
`var.ingress_rules`. Inside `content`, `ingress.value` is the current object.
This avoids duplicating nearly identical nested blocks when the rule list
changes.

The current [`terraform.tfvars`](./terraform.tfvars) permits TCP traffic on
ports 22, 80, and 443 from one `/32` address. Replace that address with the
intended trusted source before using the configuration.

## VPC data source

[`data.tf`](./data.tf) first reads all VPC IDs with `aws_vpcs.all`, then uses
`for_each` to retrieve each VPC's details with `aws_vpc.details`. The
`existing_vpcs` output returns each VPC's CIDR block, default-VPC status, and
tags. This is useful for inspection, but it does not automatically select a
VPC for the security group.

## Mistakes and corrections

| Mistake or risk | Correction |
| --- | --- |
| The directory README described an EC2 `cpu_options` example instead of the current security-group code. | Document the actual dynamic ingress and VPC data-source configuration. |
| `cpu_options = ...` was treated as if a nested provider block were a normal argument in the earlier exercise. | Use the provider-required block form, and use `dynamic` only when repeated nested blocks need to be generated. |
| The folder name suggests conditional expressions, but the current resource always creates its dynamic ingress blocks. | Add a conditional `for_each` expression only when the ingress block itself must be optional; do not describe that behavior as implemented yet. |
| `vpc_id` is currently a hard-coded placeholder (`vpc-0e7f3b8c9d1a2b3c4`). | Replace it with a real VPC ID or derive a deliberately selected VPC from a data source before `plan` or `apply`. |
| The VPC data source lists every VPC but does not choose one for the security group. | Add an explicit selection rule if the security group should use a discovered VPC. Do not select an arbitrary VPC. |
| A `/32` address in `terraform.tfvars` grants access only to one public IPv4 address. | Confirm the address is correct and keep the range as narrow as the use case permits. |
| The ingress rules do not define an egress policy. | Review the AWS provider default egress behavior and add an explicit `egress` block if least-privilege egress is required. |

## Terraform workflow

Run these commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
terraform refresh
```

Before `plan` or `apply`, confirm that:

- Terraform is `1.10.0` or newer.
- The AWS CLI profile `terraform-dev` exists and can access `ap-south-1`.
- The hard-coded placeholder VPC ID has been replaced or intentionally wired
  to a selected data-source result.
- The source IP in `terraform.tfvars` is correct.
- The selected account has permission to create and delete security groups.

`terraform validate` checks Terraform syntax and references but does not prove
that the VPC exists, credentials work, the profile has permissions, or the
security group can be created. Those checks occur during `plan` and `apply`.

## Key learnings

- `dynamic` generates nested blocks; it does not generate top-level resources.
- `for_each` controls how many nested blocks are created.
- The dynamic block label (`ingress`) becomes the object name used in
  `ingress.value`.
- Typed object variables make each generated rule predictable.
- Data sources can inspect existing infrastructure, but a lookup alone does
  not connect that infrastructure to a resource.
- Validate network ranges and resource identifiers before applying changes.
