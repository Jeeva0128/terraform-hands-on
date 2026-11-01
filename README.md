# Day 03: Provisioning AWS S3 Buckets with Terraform

## Introduction

On Day 03 of my practical DevOps learning journey, I used Terraform to provision
Amazon S3 buckets. The objective was to practice the basic Terraform workflow,
understand how an AWS provider version affects documentation, verify the
resource in AWS, and clean up the test infrastructure safely.

This was a beginner-level Infrastructure as Code lab. I focused on applying the
workflow end to end rather than building a production-ready S3 design.

## Learning Objectives

- Configure the HashiCorp AWS provider in Terraform.
- Define an S3 bucket with a Terraform resource block.
- Understand resource types, local resource names, attributes, and tags.
- Match Terraform configuration with the installed AWS provider documentation.
- Initialize Terraform and create an AWS resource.
- Verify the resource in AWS.
- Inspect Terraform-managed state.
- Destroy test infrastructure with Terraform.

## Prerequisites

Before starting this lab, I needed:

- An AWS account.
- Terraform installed and available in the terminal.
- AWS CLI installed.
- AWS credentials configured securely.
- Permission to create and delete S3 buckets.
- A text editor and terminal.

> **Security note:** Credentials must not be written into a committed Terraform
> file. The provider file used during this practice contained credential
> material, which is intentionally not reproduced here. If credentials have
> been exposed, they should be revoked or rotated immediately.

## Understanding Terraform Resource Blocks

A Terraform resource block has the following general structure:

```hcl
resource "<RESOURCE_TYPE>" "<LOCAL_RESOURCE_NAME>" {
  # arguments
}
```

The parts of the block are:

| Part | Meaning |
| --- | --- |
| `resource` | Terraform's block type for managing an infrastructure object. |
| `aws_s3_bucket` | The AWS provider resource type for an S3 bucket. |
| `example` | A local name used to refer to the resource inside Terraform. |
| `bucket` | The bucket name supplied to AWS. |
| `tags` | Key-value metadata attached to the bucket. |

The local resource name is not the AWS bucket name. It is an identifier used in
Terraform configuration and state.

## Implementation

### 1. Configure the AWS provider

The provider configuration used the HashiCorp AWS provider and constrained it
to the version family beginning with `6`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  # Credentials are intentionally omitted from this public example.
}
```

The region in the practice configuration was `ap-south-1`. Credentials should
come from a secure AWS-supported mechanism rather than being hard-coded.

### 2. Define the S3 resources

The Terraform configuration defined two S3 bucket resources:

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket11-jeevanandan"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "example2" {
  bucket = "my-tf-test-bucket12-jeevanandan"

  tags = {
    Name        = "My updated bucket"
    Environment = "Dev"
  }
}
```

Each resource uses the `bucket` attribute to specify the bucket name and a
`tags` map to add a name and environment classification. The second resource
has a different local name, bucket name, and `Name` tag, so Terraform treats it
as a separate resource.

The bucket names include a suffix to make them unique within Amazon S3. S3
bucket names must be globally unique, so using a personal or project-specific
suffix is a practical way to reduce naming conflicts during a lab.

## Documentation Version Issue

I initially referred to the HashiCorp AWS Provider v5 documentation while
working on the S3 resource. I later checked the provider version and found that
the relevant version was v6.57, so I switched to the v6.57 documentation.

Provider documentation is version-sensitive. Resource arguments, behavior,
examples, and deprecations can change between provider versions. Checking the
provider constraint in the Terraform configuration before consulting
documentation helps ensure that the example matches the provider Terraform will
use.

In this repository, the provider constraint is:

```hcl
version = "~>6"
```

The exact lock-file selection and the command output confirming v6.57 were not
included in the supplied evidence. They can be added here when available:

```text
[PLACEHOLDER: paste the provider version output or .terraform.lock.hcl evidence]
```

## Troubleshooting

During implementation, I encountered an error and resolved it after checking
the provider version and moving from the v5 documentation to the v6.57
documentation.

The exact error message and the precise code change used to resolve it were not
provided. To keep this article evidence-based, they are recorded as
placeholders instead of being guessed:

```text
[PLACEHOLDER: paste the exact Terraform error message]
```

```text
[PLACEHOLDER: describe the exact correction that resolved the error]
```

The practical lesson was to compare the Terraform configuration, the selected
provider version, and the documentation for that same provider version before
debugging further.

## Terraform Workflow

The lab successfully completed Terraform initialization, resource creation,
AWS verification, and destruction. The narrative confirms that `init`, the
creation workflow, state inspection, and `destroy` were used or relevant, but
the exact terminal transcript was not supplied.

The actual commands and outputs should be inserted below:

```bash
[PLACEHOLDER: paste the exact terraform init command and output]
```

```bash
[PLACEHOLDER: paste the exact terraform plan command and output, if used]
```

```bash
[PLACEHOLDER: paste the exact terraform apply command and output]
```

```bash
[PLACEHOLDER: paste the exact state inspection command and output]
```

```bash
[PLACEHOLDER: paste the exact terraform destroy command and output]
```

These commands represent distinct stages:

1. **Initialize** downloads and prepares the required provider.
2. **Plan** previews the proposed infrastructure changes.
3. **Apply** creates or updates the resources after approval.
4. **State inspection** helps confirm what Terraform is tracking.
5. **Destroy** removes the test resources managed by the configuration.

The command names above are shown only to explain the workflow. The exact
commands used in this lab must be confirmed from the original terminal
transcript before replacing the placeholders.

## AWS Verification

After applying the Terraform configuration, I verified that the S3 bucket
resource had been created in AWS. I then used Terraform to destroy the test
bucket successfully.

No AWS Console screenshot, CLI command, or terminal output was supplied with
the lab details. The verification evidence can be added here:

```text
[PLACEHOLDER: add the AWS Console path or exact AWS CLI verification command]
[PLACEHOLDER: add the relevant verification output or screenshot]
```

## Cleanup

I used Terraform destroy to remove the test bucket after verification. Cleanup
is important because it prevents temporary lab resources from remaining in the
AWS account and helps avoid unnecessary charges.

Terraform destroy also reinforces the value of declarative infrastructure:
Terraform removes the resources it manages according to the configuration and
state rather than requiring manual deletion in the AWS Console.

## Key Learnings

- Terraform provider versions should be checked before using provider
  documentation.
- The AWS provider version constraint is part of the Terraform configuration
  and influences which documentation applies.
- An S3 bucket is represented with the `aws_s3_bucket` resource type.
- The Terraform local resource name and the AWS bucket name serve different
  purposes.
- Tags provide useful metadata for identifying resources.
- The Terraform workflow includes initialization, planning, applying, state
  inspection, verification, and cleanup.
- Test infrastructure should be destroyed after the experiment is complete.
- Credentials should be handled outside publicly committed Terraform files.

## Challenges Faced

The main challenges in this lab were:

1. Starting with documentation for AWS Provider v5 when the relevant provider
   version was v6.57.
2. Encountering and resolving an implementation error.
3. Confirming that the resource was created in AWS before destroying it.

The exact error text, correction, and verification evidence are intentionally
left as placeholders until the original terminal output and screenshots are
available.

## Conclusion

This lab gave me practical experience provisioning an AWS S3 resource with
Terraform. I learned that provider-version alignment is an important part of
working with Terraform documentation, and I completed the full resource
lifecycle: initialization, creation, AWS verification, and cleanup.

## Next Step

My next Terraform learning topic will build on this workflow by introducing
the next Infrastructure as Code concept from my learning plan, such as
Terraform variables and outputs.
# terraform-hands-on
