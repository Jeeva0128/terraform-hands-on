# Terraform Hands-on: Day 02

This exercise continues the Terraform hands-on by creating and managing an
Amazon S3 bucket with versioning enabled. It also introduces Terraform version
constraints, provider version constraints, and remote state stored in Amazon
S3.

## Overall Terraform Hands-on Flow

The same workflow can be used for each hands-on exercise in this repository:

1. **Write configuration** - Define the Terraform version, providers, and
   infrastructure resources in `.tf` files.
2. **Initialize** - Download providers and configure the backend.
3. **Format and validate** - Check formatting and configuration syntax.
4. **Plan** - Review the changes Terraform intends to make.
5. **Apply** - Create or update the infrastructure after approval.
6. **Verify** - Confirm the resource and its settings in AWS or with Terraform.
7. **Inspect state** - Use Terraform state commands to understand managed
   resources.
8. **Destroy when finished** - Remove temporary lab resources to avoid
   unnecessary cost.

Typical commands:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
terraform destroy
```

## Day 02 Objectives

- Configure the AWS provider for the `ap-south-1` region.
- Pin the Terraform CLI to version `1.10.0` or newer.
- Use the AWS provider from the `hashicorp/aws` registry.
- Create an S3 bucket with tags.
- Enable S3 bucket versioning.
- Store Terraform state in an encrypted S3 backend with native lock-file
  locking.

## Files

| File | Purpose |
| --- | --- |
| [`main.tf`](./main.tf) | Defines the S3 bucket and its versioning configuration. |
| [`provider.tf`](./provider.tf) | Configures the AWS provider, region, and AWS CLI profile. |
| [`version.tf`](./version.tf) | Defines Terraform/provider versions and the remote S3 backend. |
| [`.terraform.lock.hcl`](./.terraform.lock.hcl) | Records the selected provider version and checksums. |

## Implementation

### AWS provider

The provider is configured for Mumbai (`ap-south-1`) and uses the local AWS
CLI profile named `terraform-dev`:

```hcl
provider "aws" {
  region  = "ap-south-1"
  profile = "terraform-dev"
}
```

The profile must already exist in the local AWS CLI configuration. Credentials
should not be committed to Terraform files.

### S3 bucket

The bucket is created with a globally unique name and development tags:

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-jeevaram"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

S3 bucket names are globally unique. If AWS reports that this name is already
in use, replace it with a unique project or account suffix before running
`terraform apply`.

### S3 versioning

Versioning is managed as a separate resource and references the bucket through
Terraform's resource dependency:

```hcl
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

Using `aws_s3_bucket.my_bucket.id` avoids hard-coding the bucket identifier and
ensures that Terraform enables versioning on the bucket it created.

### Terraform and provider versions

The configuration requires Terraform `1.10.0` or newer and AWS provider
versions compatible with `6.57`:

```hcl
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57"
    }
  }
}
```

The lock file preserves the provider selection and checksums so initialization
is repeatable across machines.

## Problems and Solutions

| Problem | Solution |
| --- | --- |
| Terraform may use a different CLI version on another machine. | Add `required_version = ">= 1.10.0"` so Terraform checks the supported CLI version during initialization. |
| Provider documentation and behavior can differ between major versions. | Constrain the AWS provider with `version = "~> 6.57"` and use documentation for the selected provider family. |
| S3 bucket names must be unique across all AWS accounts. | Use a project-specific or random suffix and change the `bucket` value if AWS reports a naming conflict. |
| The bucket needs safe recovery from accidental overwrites or deletions. | Add `aws_s3_bucket_versioning` and set `status = "Enabled"`. |
| Terraform state stored only on one laptop is difficult to share and recover. | Configure an encrypted S3 backend so state is stored remotely. |
| Multiple operators could update the same state at the same time. | Enable S3 native state locking with `use_lockfile = true`. |
| The backend key currently says `day04/terraform.tfstate` even though this is Day 02. | Change the backend `key` to a Day 02 path, such as `day02/terraform.tfstate`, before initializing this directory if the state should be isolated by exercise. |
| Hard-coded AWS credentials could leak through source control. | Use the `terraform-dev` AWS CLI profile or another supported credential mechanism; do not place secrets in `.tf` files. |

## Remote Backend Prerequisites

Before `terraform init`, confirm that:

- The S3 bucket `terraform-state-lab-2026-random123` already exists.
- The bucket is in `ap-south-1`.
- The AWS profile `terraform-dev` can read and write the state bucket.
- The backend key is intentionally selected for this exercise.

The current backend configuration is:

```hcl
backend "s3" {
  bucket       = "terraform-state-lab-2026-random123"
  key          = "day04/terraform.tfstate"
  region       = "ap-south-1"
  encrypt      = true
  use_lockfile = true
}
```

For a Day 02 state file, update the key before initialization:

```hcl
key = "day02/terraform.tfstate"
```

Do not use a backend bucket that does not belong to you or that you are not
authorized to access.

## Verification Checklist

After applying the configuration:

```bash
terraform state list
terraform show
```

Verify in AWS that:

- The bucket exists in `ap-south-1`.
- The `Name` and `Environment` tags are present.
- Bucket versioning is enabled.
- Terraform state is stored under the intended backend key.

After verification, clean up the lab resources:

```bash
terraform destroy
```

The remote state bucket is a shared backend prerequisite and should not be
destroyed as part of this exercise unless it was created specifically for this
lab and is no longer needed.

## Key Takeaways

- Terraform configuration is declarative: describe the desired infrastructure,
  then let Terraform calculate the changes.
- Provider and Terraform version constraints make the exercise more
  predictable.
- Resource references create dependencies without repeating values.
- Remote, encrypted state and state locking are important when working in a
  team.
- Always plan, verify, and clean up temporary cloud resources.
