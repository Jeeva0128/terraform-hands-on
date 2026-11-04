# Terraform Hands-on: Dynamic and Conditional Configuration

This exercise provisions an Amazon EC2 instance and supplies its CPU settings
through Terraform variables. It demonstrates how list and map values can drive
resource arguments and nested configuration blocks.

> **Implementation note:** The current configuration uses a map to populate the
> `cpu_options` block. It does not yet use Terraform's `dynamic` block syntax
> or a conditional (`condition ? true_value : false_value`) expression.

## Validation Status

The current configuration was checked from this directory with:

```text
$ terraform fmt -check
$ terraform validate
Success! The configuration is valid.
```

`terraform validate` confirms the configuration syntax and internal references.
It does not confirm AWS credentials, AMI availability, permissions, quotas, or
whether the EC2 instance can be created. Those checks occur during `plan` and
`apply`.

## Terminal Results

The exercise was initialized successfully with Terraform and AWS provider
version `6.71.0`:

```text
$ terraform init
Initializing the backend...
- Finding hashicorp/aws versions matching "~> 6.57"...
- Installing hashicorp/aws v6.71.0...
- Installed hashicorp/aws v6.71.0 (signed by HashiCorp)
Terraform has been successfully initialized!
```

The lock file records the selected provider version, so subsequent
initialization can reproduce the provider selection.

### Initial plan error

The first `terraform plan` failed when `cpu_options` was written as an
argument:

```text
Error: Unsupported argument
An argument named "cpu_options" is not expected here.
Did you mean to define a block of type "cpu_options"?
```

The fix was to use the nested block form in [`main.tf`](./main.tf):

```hcl
cpu_options {
  core_count       = var.cpu_core_count["core_count"]
  threads_per_core = var.cpu_core_count["threads_per_core"]
}
```

Terraform distinguishes between arguments assigned with `=` and nested blocks
declared with braces. The AWS provider schema expects `cpu_options` as a block,
not as a map argument.

### Successful plan

After correcting the syntax, `terraform plan` completed successfully:

```text
Terraform will perform the following actions:

  # aws_instance.terra-instance will be created
  + aws_instance.terra-instance

      ami           = "ami-0912f71e06545ad88"
      instance_type = "t2.large"

      cpu_options {
        core_count       = 1
        threads_per_core = 1
      }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_id = (known after apply)
```

The plan confirms that the list value from `terraform.tfvars` selects
`t2.large`, the CPU map produces one core and one thread per core, and the
instance ID remains unknown until AWS creates the instance. Because the plan
was not saved with `-out`, Terraform warned that a later apply might not
execute exactly the reviewed plan.

## Objectives

- Configure the AWS provider for `ap-south-1`.
- Define an EC2 instance with `aws_instance`.
- Select an instance type from a list variable.
- Read CPU settings from a map variable.
- Reuse a resource attribute through a local value.
- Expose the instance ID as a Terraform output.

## Files

| File | Purpose |
| --- | --- |
| [`main.tf`](./main.tf) | Defines the EC2 instance and its `cpu_options` block. |
| [`provider.tf`](./provider.tf) | Configures Terraform, the AWS provider, region, and AWS CLI profile. |
| [`variable.tf`](./variable.tf) | Declares the AMI, instance type, and CPU settings variables. |
| [`terraform.tfvars`](./terraform.tfvars) | Overrides the instance type with `t2.large`. |
| [`locals.tf`](./locals.tf) | Creates a reusable local value for the instance ID. |
| [`output.tf`](./output.tf) | Outputs the created instance ID. |
| [`.terraform.lock.hcl`](./.terraform.lock.hcl) | Records the selected provider version and checksums. |

## Configuration Breakdown

### EC2 instance

The resource uses the AMI and the first value in the instance-type list:

```hcl
resource "aws_instance" "terra-instance" {
  ami           = var.ami_ec2
  instance_type = var.instance_type[0]

  cpu_options {
    core_count       = var.cpu_core_count["core_count"]
    threads_per_core = var.cpu_core_count["threads_per_core"]
  }
}
```

The current [`terraform.tfvars`](./terraform.tfvars) selects `t2.large`.
The AMI must exist in `ap-south-1` and support the selected instance type
before applying the configuration.

The configuration currently has no `tags`, subnet, security group, key pair, or
explicit networking settings. AWS provider defaults and the account's default
VPC/subnet behavior therefore affect whether the instance can be created and
whether it receives a public IP.

### Map-driven CPU options

The CPU configuration is represented as a map:

```hcl
variable "cpu_core_count" {
  type = map(number)

  default = {
    core_count       = 1
    threads_per_core = 1
  }
}
```

The resource reads each map value by key. This keeps the values separate from
the resource block and makes them easy to override. AWS still validates
whether the selected instance type supports the requested CPU configuration.

### Locals and outputs

The local references the instance ID:

```hcl
locals {
  instance_id = aws_instance.terra-instance.id
}
```

The output exposes that local value after the instance is created:

```hcl
output "instance_id" {
  value = local.instance_id
}
```

Terraform resource names may contain hyphens, but references must use the exact
declared resource name, as shown above.

## Dynamic and Conditional Concepts

The current exercise demonstrates configuration driven by variable data rather
than a true `dynamic` block. A future extension could use a dynamic block when
the entire `cpu_options` block should be optional:

```hcl
dynamic "cpu_options" {
  for_each = var.enable_cpu_options ? [var.cpu_core_count] : []

  content {
    core_count       = cpu_options.value["core_count"]
    threads_per_core = cpu_options.value["threads_per_core"]
  }
}
```

That pattern combines:

- A conditional expression to choose whether the block is created.
- `for_each` to create zero or one nested block.
- `content` to define the generated block arguments.

This example is explanatory only; `enable_cpu_options` is not currently
declared in the exercise.

The `cpu_options` block is not optional in the current `main.tf`; it is always
present. To make it optional, the example must be implemented in the resource
and the `enable_cpu_options` variable must be declared with a default value.

## Terraform Workflow

Run the commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output instance_id
terraform state list
terraform destroy
```

For a safe run, inspect the plan before approving `apply`:

```bash
terraform plan -out=tfplan
terraform apply tfplan
terraform output instance_id
```

The plan should contain one `aws_instance.terra-instance` resource. The output
is unknown until AWS creates the instance, after which `terraform output
instance_id` should return its EC2 instance ID. Do not commit `tfplan`; it may
contain infrastructure details.

The observed unsaved-plan warning is avoided by using:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

Before `terraform apply`, verify that:

- The `terraform-dev` AWS CLI profile is configured.
- The AMI exists in `ap-south-1`.
- The AMI architecture and CPU settings are compatible with `t2.large`.
- The AWS identity has permission to create and delete EC2 instances.

Destroy the instance after verification to avoid unnecessary AWS charges.

## Troubleshooting

| Symptom | Likely cause | Resolution |
| --- | --- | --- |
| `InvalidAMIID.NotFound` | The AMI is unavailable in `ap-south-1`. | Select an AMI available in the configured region. |
| CPU option validation fails during `plan` or `apply` | The requested CPU settings are not supported by the selected instance type. | Check the EC2 instance-type specifications and adjust `cpu_core_count`. |
| `NoCredentialProviders` or an access-denied error | The `terraform-dev` profile is missing or lacks EC2 permissions. | Configure a supported AWS credential source and verify the profile's permissions. |
| `terraform output instance_id` has no value | The instance has not been applied successfully or state is not available. | Complete `terraform apply` from this directory and inspect `terraform state list`. |
| A future dynamic-block example reports an undeclared variable | `enable_cpu_options` exists only in the documentation example. | Declare the variable and implement the dynamic block before using that example. |

## Key Learnings

- Lists can provide selectable resource arguments.
- Maps can centralize related configuration values.
- Locals provide readable names for derived resource attributes.
- `dynamic` blocks are useful when nested blocks must be generated
  conditionally.
- Variable-driven configuration should still be validated against provider and
  resource constraints.