# Terraform Hands-on Practice

This repository contains independent Terraform exercises for learning AWS
infrastructure as code. Each directory is a separate Terraform root module
with its own provider configuration, state, lock file, and documentation.

The exercises progress from basic AWS resources to variables, remote state,
meta-arguments, data sources, and dynamic nested blocks. They are learning
examples rather than production-ready infrastructure modules.

## Learning path

| Exercise | Main topic | What it demonstrates | Documentation |
| --- | --- | --- | --- |
| [`provider-plugin/`](./provider-plugin/) | AWS provider and S3 resources | Configure the AWS provider and create two tagged S3 buckets. | [`README.md`](./provider-plugin/README.md) |
| [`reource-practice/`](./reource-practice/) | S3 versioning and remote state | Create a versioned S3 bucket and configure an encrypted S3 backend with native locking. | [`README.md`](./reource-practice/README.md) |
| [`variables-tf/`](./variables-tf/) | EC2, variables, locals, and outputs | Launch an EC2 instance using typed variables, `.tfvars`, locals, and outputs. | [`README.md`](./variables-tf/README.md) |
| [`meta-arguments/`](./meta-arguments/) | `count` | Create multiple S3 buckets from one resource block and use indexed addresses. | [`README.md`](./meta-arguments/README.md) |
| [`Dynamic-conditional expression/`](./Dynamic-conditional%20expression/) | Dynamic nested blocks and data sources | Generate security-group ingress blocks from a typed rule list and inspect existing VPCs. | [`README.md`](./Dynamic-conditional%20expression/README.md) |

> The directory name `reource-practice` is retained from the repository and is
> intentionally not renamed by the documentation.

## Repository structure

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
│   ├── terraform.tfvars
│   ├── locals.tf
│   ├── output.tf
│   └── README.md
├── Dynamic-conditional expression/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── data.tf
│   ├── outputs.tf
│   └── README.md
└── README.md
```

Terraform loads all `.tf` files in a module; filenames do not control
evaluation order. This repository uses names such as `provider.tf` and
`version.tf` to organize configuration, but some modules place the version
constraint and provider block in different files.

Generated state, provider packages, and local Terraform directories should not
be committed. The module `.gitignore` files and the repository ignore rules
provide the initial protection for local artifacts.

## Prerequisites

- Terraform CLI `1.10.0` or newer for the modules that declare that minimum.
- An AWS account with permission to create, inspect, and delete the lab
  resources.
- AWS CLI credentials configured through the `terraform-dev` profile or
  another supported credential mechanism.
- Access to the AWS `ap-south-1` region.
- Globally unique names for S3 buckets.

The `provider-plugin` module currently constrains the AWS provider to the
`~> 6` family but does not declare a Terraform CLI minimum. The other modules
use the AWS provider constraint `~> 6.57` and declare
`required_version = ">= 1.10.0"`.

Never commit AWS credentials, access keys, private keys, or other secrets.

## Common workflow

Run Terraform from one exercise directory at a time. Do not initialize or
apply from the repository root because the root has no Terraform module.

```bash
cd <exercise-directory>
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

Use the following sequence:

1. **Initialize** - Install the required provider and configure any backend.
2. **Format** - Apply Terraform's canonical formatting.
3. **Validate** - Check syntax, types, and references locally.
4. **Plan** - Review the proposed infrastructure changes.
5. **Apply** - Create or update resources only after reviewing the plan.
6. **Verify** - Inspect outputs, state, and the AWS console or CLI.
7. **Destroy** - Remove temporary resources after the exercise.

`terraform validate` does not prove that AWS credentials, permissions,
availability zones, AMIs, VPC IDs, bucket names, or quotas are correct. Those
conditions are checked during `plan` and `apply`.

## Exercise details

### 1. AWS provider and S3 resources

[`provider-plugin/`](./provider-plugin/) is the introductory exercise. It
declares two `aws_s3_bucket` resources with tags and uses the AWS provider in
`ap-south-1`.

Key lessons:

- A provider connects Terraform to AWS.
- The Terraform resource name is a local reference, not the S3 bucket name.
- S3 bucket names are globally unique.
- Provider documentation must match the configured provider family.

Before applying, confirm that both bucket names are available and that the
configured AWS profile can create and delete S3 buckets.

### 2. S3 versioning and remote state

[`reource-practice/`](./reource-practice/) creates one tagged S3 bucket and
enables versioning through `aws_s3_bucket_versioning`. Its `version.tf`
configures an encrypted S3 backend with `use_lockfile = true`.

The backend currently uses:

```hcl
bucket       = "terraform-state-lab-2026-random123"
key          = "day04/terraform.tfstate"
region       = "ap-south-1"
encrypt      = true
use_lockfile = true
```

The backend bucket must already exist, belong to the operator, and be
accessible with the configured AWS profile. The `day04` key is a repository
configuration detail, not a guarantee about the exercise's sequence. Change
the key before initialization if a separate state path is required. Never
destroy a shared backend bucket as part of cleaning up this exercise.

### 3. EC2, variables, locals, and outputs

[`variables-tf/`](./variables-tf/) creates an `aws_instance` using:

- AMI `ami-0912f71e06545ad88`.
- The first value in the `instance_type` list.
- The first value in the `environment` list.
- The `project_name` string for the `Name` tag.
- Values supplied through `terraform.tfvars`.

The current variables file sets `instance_type = ["t2.large"]`. The AMI is
region- and architecture-specific, so verify that it exists in `ap-south-1`
and supports the selected instance type before applying.

The module also defines locals and outputs for the instance ID, ARN, private
IP, and public IP. Its `region` variable is currently declared but not used by
the provider, which is configured directly for `ap-south-1`. The list-based
instance type and environment variables demonstrate indexing; scalar strings
would be simpler if only one value were ever needed.

EC2 instances can incur charges. Destroy the instance after verification.

### 4. `count` meta-argument

[`meta-arguments/`](./meta-arguments/) creates one S3 bucket for each suffix in
`var.bucket_name_suffix`:

```hcl
count = length(var.bucket_name_suffix)
bucket = "${var.bucket_name}-${var.bucket_name_suffix[count.index]}"
```

The default suffix list contains five values, so the expected resource
addresses are:

```text
aws_s3_bucket.my_bucket[0]
aws_s3_bucket.my_bucket[1]
aws_s3_bucket.my_bucket[2]
aws_s3_bucket.my_bucket[3]
aws_s3_bucket.my_bucket[4]
```

The exercise also records a common mistake: Terraform expressions must not be
quoted when they should be evaluated. The current local/output example
intentionally documents the correction from a quoted expression and an
incorrect resource name to `aws_s3_bucket.my_bucket[*].id`.

### 5. Dynamic blocks and VPC data sources

[`Dynamic-conditional expression/`](./Dynamic-conditional%20expression/) creates
an `aws_security_group` and generates one nested `ingress` block per object in
`var.ingress_rules`:

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

The module's `data.tf` lists all VPCs in the configured region and exposes
their IDs, CIDR blocks, default status, and tags through `existing_vpcs`.
Those data sources do not select a VPC for the security group.

Before applying:

- Replace the placeholder `vpc_id` in `main.tf` with a real, deliberately
  selected VPC ID, or add an explicit selection rule.
- Verify the `/32` source address in `terraform.tfvars`.
- Review whether the default egress behavior is appropriate.
- Treat the current configuration as a dynamic-block example; it does not
  currently conditionally omit the entire ingress block.

## Known issues and safety checks

| Area | Current condition | Required check |
| --- | --- | --- |
| Backend | The S3 backend uses a pre-existing bucket and a `day04` state key. | Confirm ownership, permissions, and the intended state path before `terraform init`. |
| S3 naming | Several exercises use fixed bucket names. | Change names if they are already taken globally. |
| EC2 AMI | The AMI is hard-coded and region-specific. | Verify availability and architecture in `ap-south-1`. |
| EC2 region variable | `variables-tf` declares `region`, but the provider uses a literal region. | Do not assume changing the variable changes the provider region. |
| Security group VPC | The dynamic-block module contains a placeholder VPC ID. | Replace or explicitly derive the ID before planning. |
| Network access | The dynamic-block module opens ports 22, 80, and 443 to one configured `/32`. | Confirm the source IP and keep ingress ranges narrow. |
| State and cost | Applying creates real AWS resources and state. | Review plans, protect remote state, and destroy temporary resources. |

## Useful verification commands

From an exercise directory:

```bash
terraform fmt -check
terraform validate
terraform plan
terraform state list
terraform show
terraform output
```

For the remote-state exercise, verify the backend key before running
`terraform init`. For all exercises, inspect the plan for unexpected
resources, addresses, regions, and network exposure.

## Key learnings

- Terraform describes desired state declaratively.
- Providers, resources, data sources, variables, locals, and outputs have
  different roles.
- Resource references create dependencies automatically.
- `count` creates indexed resource instances, while `dynamic` creates nested
  blocks.
- Typed variables make repeated configuration predictable.
- Version constraints and lock files improve repeatability.
- Remote state and locking support safer collaboration.
- Planning, verification, and cleanup are essential when practicing against
  real cloud accounts.
