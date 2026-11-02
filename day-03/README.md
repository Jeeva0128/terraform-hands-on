# Terraform Hands-on: Day 03

Day 03 moves from S3 resources to launching an Amazon EC2 instance with
Terraform. The exercise introduces input variables, variable values supplied
through `terraform.tfvars`, local values, resource references, and output
values.

## Objectives

- Configure the AWS provider for `ap-south-1`.
- Define an EC2 instance with `aws_instance`.
- Use variables instead of hard-coding every configuration value.
- Use `terraform.tfvars` to provide environment-specific values.
- Create local values from resource attributes.
- Print the instance ID, ARN, private IP, and public IP as Terraform outputs.
- Validate variable types and AMI/instance compatibility before applying.

## Files

| File | Purpose |
| --- | --- |
| [`main.tf`](./main.tf) | Defines the EC2 instance and its tags. |
| [`provider.tf`](./provider.tf) | Configures the AWS provider, region, and AWS CLI profile. |
| [`version.tf`](./version.tf) | Defines the Terraform and AWS provider version constraints. |
| [`variables.tf`](./variables.tf) | Declares input variables and their types/defaults. |
| [`terraform.tfvars`](./terraform.tfvars) | Supplies values for the current exercise. |
| [`locals.tf`](./locals.tf) | Creates reusable values from the EC2 resource attributes. |
| [`output.tf`](./output.tf) | Exposes useful instance information after apply. |

## Configuration Breakdown

### AWS provider

The provider targets the Mumbai region and uses the local AWS CLI profile
`terraform-dev`:

```hcl
provider "aws" {
  region  = "ap-south-1"
  profile = "terraform-dev"
}
```

The profile must be configured locally with permission to create, inspect, and
delete EC2 instances. Credentials should not be stored in Terraform files.

### EC2 instance

The main resource uses an AMI, an instance type, and tags:

```hcl
resource "aws_instance" "my_instance" {
  ami           = "ami-0912f71e06545ad88"
  instance_type = var.instance_type[0]

  tags = {
    Name        = var.project_name
    Environment = var.environment[0]
  }
}
```

The AMI is region-specific. An AMI that works in `ap-south-1` may not be
available in another region, so the AMI should be verified before applying.

### Input variables

The exercise declares lists for region, instance type, and environment, plus a
string project name:

```hcl
variable "instance_type" {
  type    = list(string)
  default = ["t2.micro", "t2.small", "t3.micro"]
}

variable "environment" {
  type    = list(string)
  default = ["dev", "prod"]
}

variable "project_name" {
  type    = string
  default = "Terraform demo"
}
```

The resource selects the first list item with `[0]`. This demonstrates list
indexing, but a scalar `string` variable would be simpler when only one value
is required.

### Variable values

The current [`terraform.tfvars`](./terraform.tfvars) contains:

```hcl
instance_type = ["t2.large"]
```

This matches the declaration `type = list(string)`. The resource selects
`"t2.large"` with `var.instance_type[0]`.

If only one instance type is required, a scalar variable is also possible:

```hcl
variable "instance_type" {
  type    = string
  default = "t2.large"
}
```

Then update the resource to remove list indexing:

```hcl
instance_type = var.instance_type
```

The current exercise keeps the list-based design to demonstrate list indexing.
The selected `t2.large` is x86-based, so the AMI architecture should still be
checked before provisioning.

### Locals and outputs

The local values collect attributes from the created instance:

```hcl
locals {
  instance_id = aws_instance.my_instance.id
  arn         = aws_instance.my_instance.arn
  private_ip  = aws_instance.my_instance.private_ip
  public_ip   = aws_instance.my_instance.public_ip
}
```

The outputs expose those values:

```hcl
output "instance_id" {
  value = local.instance_id
}
```

The public IP may be unknown until the instance is created, and it may be
absent if the instance is launched without public networking. Outputs should
therefore be inspected after `terraform apply`.

## Problems and Solutions

| Problem | Solution |
| --- | --- |
| An EC2 instance needs a region-specific image. | Use an AMI available in `ap-south-1` and verify its architecture matches the selected instance type. |
| Values hard-coded in resources are difficult to reuse. | Declare input variables and reference them from `main.tf`. |
| The instance type is supplied from a separate variable file. | Keep `terraform.tfvars` compatible with `type = list(string)`; the current value is `["t2.large"]`. |
| Resource attributes are needed in several places. | Define locals from `aws_instance.my_instance` attributes and reuse the locals. |
| Users need important instance details after deployment. | Declare outputs for the instance ID, ARN, private IP, and public IP. |
| Cloud resources can continue generating charges after testing. | Run `terraform destroy` after verification. |
| Credentials could be exposed in source control. | Use the `terraform-dev` AWS profile or another secure AWS credential mechanism. |

## Terraform Workflow

Run these commands from the `day-03` directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

The important order is:

1. `terraform init` installs the locked AWS provider.
2. `terraform fmt` formats the configuration.
3. `terraform validate` catches syntax and type errors.
4. `terraform plan` previews the EC2 instance changes.
5. `terraform apply` creates the instance after approval.
6. `terraform output` displays the generated values.
7. `terraform destroy` removes the test instance.

Before `apply`, confirm that the AMI exists in `ap-south-1` and is compatible
with the selected `t2.large` instance type.

## Verification Checklist

After applying the corrected configuration, verify that:

- The instance is running in `ap-south-1`.
- The instance type is the intended value.
- The `Name` and `Environment` tags are present.
- `terraform output` returns the expected instance ID and ARN.
- The private and public IP values match the networking configuration.
- The instance is destroyed after the hands-on is complete.

## Key Learnings

- Variables make Terraform configurations reusable.
- Variable types must match values supplied through `.tfvars`; the current
  value is a list containing `t2.large`.
- Locals provide readable names for derived values.
- Outputs expose resource information for users and automation.
- AMI architecture and region must match the EC2 instance configuration.
- Validation and planning should happen before provisioning cloud resources.
