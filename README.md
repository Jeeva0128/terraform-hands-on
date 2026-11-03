# Terraform Hands-on Practice

This repository contains independent Terraform and AWS hands-on exercises.
Each directory focuses on a core Terraform concept such as providers,
resources, variables, and meta-arguments.

## Project Goals

- Learn Terraform configuration using real AWS resources.
- Understand providers, resources, attributes, tags, and dependencies.
- Practice the Terraform lifecycle from initialization to cleanup.
- Introduce provider and Terraform version constraints.
- Use remote, encrypted state and state locking.
- Record the problems encountered during each hands-on and their solutions.

## Hands-on Progress

| Exercise | Main topic | AWS/Terraform work | Documentation |
| --- | --- | --- | --- |
| `provider-plugin` | AWS provider and S3 resources | Configure the AWS provider and create two tagged S3 buckets. | [`provider-plugin/README.md`](./provider-plugin/README.md) |
| `reource-practice` | S3 versioning and remote state | Create a versioned S3 bucket and configure an encrypted S3 backend. | [`reource-practice/README.md`](./reource-practice/README.md) |
| `variables-tf` | EC2, variables, locals, and outputs | Launch an EC2 instance using variables, `.tfvars`, local values, and outputs. | [`variables-tf/README.md`](./variables-tf/README.md) |
| `meta-arguments` | `count` meta-argument | Create multiple S3 buckets from one resource block using a suffix list. | [`meta-arguments/README.md`](./meta-arguments/README.md) |

## Repository Structure

```text
terraform-practice/
├── provider-plugin/
│   ├── main.tf
│   ├── provider.tf
│   └── README.md
├── reource-practice/
│   ├── main.tf
│   ├── provider.tf
│   ├── version.tf
│   └── README.md
├── variables-tf/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── locals.tf
│   ├── output.tf
│   └── README.md
├── meta-arguments/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── output.tf
│   └── README.md
└── README.md
```

Terraform state, provider plugins, and other generated files should remain
outside source control. The repository `.gitignore` files provide the initial
protection for local Terraform artifacts.

## Terraform Hands-on Workflow

Run Terraform from the directory for the exercise being completed:

```bash
cd meta-arguments
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
terraform show
terraform destroy
```

The workflow is:

1. **Configure** - Write `.tf` files for the desired infrastructure.
2. **Initialize** - Install the required provider and configure the backend.
3. **Format and validate** - Check style and configuration correctness.
4. **Plan** - Review the proposed changes before modifying AWS.
5. **Apply** - Create or update the resources.
6. **Verify** - Confirm the resources and settings in AWS.
7. **Inspect state** - Confirm which resources Terraform manages.
8. **Destroy** - Remove temporary resources after the lab.

## Shared Prerequisites

- Terraform `1.10.0` or newer.
- An AWS account with permission to create and delete the lab resources.
- AWS CLI configured with the `terraform-dev` profile.
- Access to the `ap-south-1` AWS region.
- Globally unique S3 bucket names.

Never commit AWS credentials or secrets to this repository. Use an AWS CLI
profile, environment variables, or another supported credential mechanism.

## Provider and S3 Fundamentals

The `provider-plugin` exercise introduces the basic Terraform structure:

- `provider.tf` selects the HashiCorp AWS provider and `ap-south-1`.
- `main.tf` declares tagged `aws_s3_bucket` resources.
- The local resource name is used inside Terraform, while the `bucket`
  attribute is the globally unique AWS bucket name.

The main problem is turning a manual AWS resource into repeatable
configuration. The solution is to describe the desired S3 buckets in
declarative Terraform resource blocks, then use `plan`, `apply`, and `destroy`
to manage their lifecycle.

See the detailed [provider and S3 hands-on](./provider-plugin/README.md).

## S3 Versioning and Remote State

The `reource-practice` exercise extends the first exercise with:

- Terraform CLI requirement: `>= 1.10.0`.
- AWS provider constraint: `~> 6.57`.
- One tagged S3 bucket.
- S3 bucket versioning enabled through
  `aws_s3_bucket_versioning`.
- An encrypted S3 backend with native lock-file locking.

### Problems and solutions

| Problem | Solution |
| --- | --- |
| Different Terraform CLI versions can produce inconsistent results. | Set `required_version` in [`version.tf`](./reource-practice/version.tf). |
| Provider behavior and documentation vary by version. | Constrain the AWS provider and keep the lock file. |
| S3 bucket names are globally unique. | Use a project-specific suffix and change it when a name is unavailable. |
| Important bucket objects can be overwritten or deleted accidentally. | Enable S3 versioning with `aws_s3_bucket_versioning`. |
| Local state is difficult to share and recover. | Store state in an encrypted S3 backend. |
| Concurrent changes can corrupt or overwrite state. | Enable backend locking with `use_lockfile = true`. |
| Secrets can leak through source control. | Use the configured AWS profile instead of hard-coded credentials. |

The detailed [S3 versioning hands-on](./reource-practice/README.md) explains the configuration,
prerequisites, verification checklist, and cleanup process.

## EC2, Variables, Locals, and Outputs

The `variables-tf` exercise provisions an EC2 instance and builds on the
previous exercises with:

- An `aws_instance` resource in `ap-south-1`.
- Input variables for region, instance type, environment, and project name.
- `terraform.tfvars` setting the current instance type to `["t2.large"]`.
- Local values for the instance ID, ARN, private IP, and public IP.
- Terraform outputs exposing those local values.

### Problems and solutions

| Problem | Solution |
| --- | --- |
| EC2 AMIs are region-specific and architecture-specific. | Verify that the AMI in `main.tf` exists in `ap-south-1` and supports the selected instance type. |
| Hard-coded EC2 settings are difficult to reuse. | Define input variables in `variables.tf` and reference them from the resource. |
| Values in `.tfvars` must match their declared types. | Keep `instance_type = ["t2.large"]` as a list because the variable uses `list(string)`. |
| Resource attributes are needed after creation. | Define locals and outputs for the instance ID, ARN, private IP, and public IP. |
| Running instances can incur AWS charges. | Verify the outputs, then run `terraform destroy` when the lab is complete. |

See the detailed [EC2 hands-on](./variables-tf/README.md).

## Meta-arguments with `count`

The [`meta-arguments`](./meta-arguments/README.md) exercise uses Terraform's
`count` meta-argument to create one S3 bucket per suffix in a list. It also
demonstrates indexed resource addresses, list access through `count.index`,
and the difference between a quoted string and an evaluated Terraform
expression in a local value.

### Problems and solutions

| Problem | Solution |
| --- | --- |
| Several similar buckets would require repeated resource blocks. | Use `count = length(var.bucket_name_suffix)` and `count.index`. |
| Bucket names may collide globally. | Use a project-specific base name and verify generated names before applying. |
| An output can print an expression as text instead of evaluating it. | Leave Terraform references unquoted and use the exact resource name, `my_bucket`. |

See the detailed [meta-arguments hands-on](./meta-arguments/README.md).

## Backend Note

The current S3 versioning exercise backend configuration uses:

```hcl
bucket = "terraform-state-lab-2026-random123"
key    = "day04/terraform.tfstate"
region = "ap-south-1"
```

Before initializing [`reource-practice`](./reource-practice/), confirm that the
backend bucket is owned by and accessible to you. If this exercise should use
an exercise-specific state path, change the key to:

```hcl
key = "reource-practice/terraform.tfstate"
```

Do not destroy a shared backend bucket when cleaning up an individual
exercise.

## Key Learnings

- Terraform files describe desired state instead of imperative steps.
- Providers connect Terraform to platforms such as AWS.
- Resource references create dependencies automatically.
- Version constraints improve repeatability.
- Remote state and locking support safe team workflows.
- Temporary cloud resources should be verified and destroyed after practice.
