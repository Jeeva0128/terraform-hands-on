# Terraform Functions

This exercise demonstrates commonly used Terraform functions with input
variables, local values, and outputs. It does not create AWS resources; the AWS
provider is configured only to keep the module consistent with the other
hands-on exercises.

## Objectives

- Normalize and transform strings with `trimspace`, `replace`, `lower`,
  `upper`, and `substr`.
- Combine maps with `merge`.
- Convert a comma-separated string into a list with `split`.
- Extend lists with `concat` and count items with `length`.
- Build a map with a `for` expression and convert strings to numbers with
  `tonumber`.
- Select environment-specific values with `lookup`.
- Calculate values with `max`, `min`, and `abs`.
- Expose calculated values through Terraform outputs.

## Files

| File | Purpose |
| --- | --- |
| [`provider.tf`](./provider.tf) | Configures the AWS provider for `ap-south-1` using the `terraform-dev` profile. |
| [`version.tf`](./version.tf) | Sets the Terraform and AWS provider version constraints. |
| [`variables.tf`](./variables.tf) | Declares the project, environment, port, and tag inputs. |
| [`locals.tf`](./locals.tf) | Applies Terraform functions to the input values. |
| [`output.tf`](./output.tf) | Displays the calculated local values. |
| [`terraform.tfvars`](./terraform.tfvars) | Optional variable overrides for this exercise. |

## Input Variables

The defaults in [`variables.tf`](./variables.tf) are:

```hcl
project_name  = "Project ALPHA Storage"
environment   = "dev"
allowed_ports = "80,443,8080,3306"

default_tags = {
  Company   = "TechCorp"
  ManagedBy = "Terraform"
}

environment_tags = {
  CostCenter  = "CC-101"
  Environment = "dev"
}
```

You can override values in `terraform.tfvars`, for example:

```hcl
project_name  = " Project Beta Storage "
environment   = "staging"
allowed_ports = "80,443"

environment_tags = {
  CostCenter  = "CC-202"
  Environment = "staging"
}
```

The `environment` value is used to look up an instance size from this map:

```hcl
{
  dev     = "t2.micro"
  staging = "t2.small"
  prod    = "t3.large"
}
```

Unknown environments use `t2.micro` as the lookup fallback.

## Function Examples

The module calculates the following values in [`locals.tf`](./locals.tf):

| Category | Expression | Result with defaults |
| --- | --- | --- |
| String normalization | `lower(replace(trimspace(var.project_name), " ", "-"))` | `project-alpha-storage` |
| Prefix extraction | `substr(local.formatted_project_name, 0, 7)` | `project` |
| Uppercase conversion | `upper(var.project_name)` | `PROJECT ALPHA STORAGE` |
| Map merge | `merge(var.default_tags, var.environment_tags)` | A combined tag map |
| List parsing | `split(",", var.allowed_ports)` | `["80", "443", "8080", "3306"]` |
| List length | `length(local.port_list)` | `4` |
| List concatenation | `concat(local.port_list, ["9090", "3000"])` | The four input ports plus `9090` and `3000` |
| Map construction | `for port in local.port_list` | One TCP rule per port |
| String-to-number conversion | `tonumber(port)` | Numeric port values |
| Map lookup | `lookup(local.instance_sizes, var.environment, "t2.micro")` | `t2.micro` |
| Numeric maximum | `max(80, 443, 8080)` | `8080` |
| Numeric minimum | `min(80, 443, 8080)` | `80` |
| Absolute value | `abs(-25)` | `25` |

## Outputs

After evaluation, the module exposes:

- `formatted_project_name`
- `project_prefix`
- `uppercase_project`
- `merged_tags`
- `parsed_ports`
- `total_ports`
- `additional_ports`
- `security_group_rules`
- `selected_instance_size`
- `numeric_results`

The `security_group_rules` output is only data. It does not create an AWS
security group or any ingress rules.

## Terraform Workflow

Run the commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

Because this module contains no managed resources, `terraform plan` should
report no infrastructure changes. `terraform apply` evaluates the
configuration and records the output values in state; it does not provision
AWS infrastructure. Use `terraform output -json` when consuming the results
from scripts.

To clean up the local state created by this exercise:

```bash
terraform destroy
```

There are no AWS resources for `terraform destroy` to remove.

## Prerequisites

- Terraform CLI `1.10.0` or newer.
- An AWS provider installation available through `terraform init`.
- An AWS CLI profile named `terraform-dev` if provider authentication is
  required by the local Terraform setup.

This exercise does not require AWS resources or permissions. Do not commit AWS
credentials or other secrets to `terraform.tfvars`.
