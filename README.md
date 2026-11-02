# Terraform Hands-on Practice

This repository contains a day-by-day Terraform learning project. Each
directory is an independent hands-on exercise that builds practical knowledge
of Terraform, the AWS provider, resource management, state, and repeatable
infrastructure workflows.

## Project Goals

- Learn Terraform configuration using real AWS resources.
- Understand providers, resources, attributes, tags, and dependencies.
- Practice the Terraform lifecycle from initialization to cleanup.
- Introduce provider and Terraform version constraints.
- Use remote, encrypted state and state locking.
- Record the problems encountered during each hands-on and their solutions.

## Hands-on Progress

| Day | Main topic | AWS/Terraform work | Documentation |
| --- | --- | --- | --- |
| Day 01 | Terraform and AWS fundamentals | Configure the AWS provider and create tagged S3 buckets. | [`day-01/README.md`](./day-01/README.md) |
| Day 02 | S3 management and state | Create an S3 bucket, enable versioning, constrain versions, and configure an S3 backend. | [`day-02/README.md`](./day-02/README.md) |
| Day 03 | EC2, variables, locals, and outputs | Launch an EC2 instance using variables, `.tfvars`, local values, and output values. | [`day-03/README.md`](./day-03/README.md) |

## Repository Structure

```text
terraform-practice/
├── day-01/
│   ├── main.tf
│   ├── provider.tf
│   └── README.md
├── day-02/
│   ├── main.tf
│   ├── provider.tf
│   ├── version.tf
│   └── README.md
├── day-03/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
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
cd day-03
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

## Day 01: Provider and S3 Fundamentals

Day 01 introduces the basic Terraform structure:

- `provider.tf` selects the HashiCorp AWS provider and `ap-south-1`.
- `main.tf` declares tagged `aws_s3_bucket` resources.
- The local resource name is used inside Terraform, while the `bucket`
  attribute is the globally unique AWS bucket name.

The main problem is turning a manual AWS resource into repeatable
configuration. The solution is to describe the desired S3 buckets in
declarative Terraform resource blocks, then use `plan`, `apply`, and `destroy`
to manage their lifecycle.

See the detailed [Day 01 hands-on](./day-01/README.md).

## Day 02: Versioning and Remote State

Day 02 extends the first exercise with:

- Terraform CLI requirement: `>= 1.10.0`.
- AWS provider constraint: `~> 6.57`.
- One tagged S3 bucket.
- S3 bucket versioning enabled through
  `aws_s3_bucket_versioning`.
- An encrypted S3 backend with native lock-file locking.

### Problems and solutions

| Problem | Solution |
| --- | --- |
| Different Terraform CLI versions can produce inconsistent results. | Set `required_version` in [`version.tf`](./day-02/version.tf). |
| Provider behavior and documentation vary by version. | Constrain the AWS provider and keep the lock file. |
| S3 bucket names are globally unique. | Use a project-specific suffix and change it when a name is unavailable. |
| Important bucket objects can be overwritten or deleted accidentally. | Enable S3 versioning with `aws_s3_bucket_versioning`. |
| Local state is difficult to share and recover. | Store state in an encrypted S3 backend. |
| Concurrent changes can corrupt or overwrite state. | Enable backend locking with `use_lockfile = true`. |
| Secrets can leak through source control. | Use the configured AWS profile instead of hard-coded credentials. |

The detailed [Day 02 hands-on](./day-02/README.md) explains the configuration,
prerequisites, verification checklist, and cleanup process.

## Day 03: EC2, Variables, Locals, and Outputs

Day 03 provisions an EC2 instance and builds on the previous exercises with:

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

See the detailed [Day 03 hands-on](./day-03/README.md).

## Backend Note

The current Day 02 backend configuration uses:

```hcl
bucket = "terraform-state-lab-2026-random123"
key    = "day04/terraform.tfstate"
region = "ap-south-1"
```

Before initializing Day 02, confirm that the backend bucket is owned by and
accessible to you. If this exercise should use a Day 02-specific state path,
change the key to:

```hcl
key = "day02/terraform.tfstate"
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
