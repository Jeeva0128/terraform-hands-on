# Terraform Hands-on: Meta-arguments with `count`

This exercise demonstrates Terraform's `count` meta-argument by creating
multiple Amazon S3 buckets from a single resource block. The bucket names are
assembled from a shared base name and a list of suffixes.

## Objectives

- Configure the AWS provider for the `ap-south-1` region.
- Use Terraform and AWS provider version constraints.
- Create multiple resources from one declaration with `count`.
- Read list values with `count.index`.
- Use variables and local values.
- Inspect the resulting resources with Terraform commands.

## Files

| File | Purpose |
| --- | --- |
| [`main.tf`](./main.tf) | Declares the S3 bucket and applies `count`. |
| [`variables.tf`](./variables.tf) | Defines the bucket base name and suffix list. |
| [`provider.tf`](./provider.tf) | Configures the AWS provider and `terraform-dev` profile. |
| [`version.tf`](./version.tf) | Constrains Terraform and the AWS provider versions. |
| [`locals.tf`](./locals.tf) | Defines the value exposed by the output. |
| [`output.tf`](./output.tf) | Exposes the local value as `s3_ids`. |
| [`.terraform.lock.hcl`](./.terraform.lock.hcl) | Records the selected provider version and checksums. |

## Configuration

The resource uses the number of suffixes as its instance count:

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.bucket_name}-${var.bucket_name_suffix[count.index]}"
  count  = length(var.bucket_name_suffix)
  region = "ap-south-1"
}
```

With the default values, Terraform creates five bucket instances:

```text
practice-meta-argu-ments-jeeva-bucket-1
practice-meta-argu-ments-jeeva-bucket-2
practice-meta-argu-ments-jeeva-bucket-3
practice-meta-argu-ments-jeeva-bucket-4
practice-meta-argu-ments-jeeva-bucket-5
```

`count.index` starts at zero, so each resource instance selects the suffix at
the matching list index. Because S3 bucket names are globally unique, change
`bucket_name` if any generated name is already in use.

The variables use a list so the number of buckets can be changed by adding or
removing suffixes:

```hcl
variable "bucket_name_suffix" {
  type    = list(string)
  default = ["bucket-1", "bucket-2", "bucket-3", "bucket-4", "bucket-5"]
}
```

## Local and Output

The current [`locals.tf`](./locals.tf) defines `s3_ids` as a quoted string:

```hcl
locals {
  s3_ids = "aws_s3_bucket.mybucket[*].id"
}
```

Therefore, [`output.tf`](./output.tf) currently prints that literal text rather
than the IDs of the created buckets. The resource is named `my_bucket`, not
`mybucket`. To output the actual IDs, the local should be written as:

```hcl
locals {
  s3_ids = aws_s3_bucket.my_bucket[*].id
}
```

This change is intentionally documented as a follow-up correction so the
hands-on distinguishes Terraform expression syntax from quoted strings and
uses the exact resource name declared in `main.tf`.

## Terraform Workflow

Run the commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
terraform output s3_ids
terraform destroy
```

Before `apply`, confirm that:

- The AWS CLI profile `terraform-dev` exists and can create and delete S3
  buckets.
- The generated bucket names are globally available.
- Terraform is `1.10.0` or newer.

After applying, `terraform state list` should show five indexed resources:

```text
aws_s3_bucket.my_bucket[0]
aws_s3_bucket.my_bucket[1]
aws_s3_bucket.my_bucket[2]
aws_s3_bucket.my_bucket[3]
aws_s3_bucket.my_bucket[4]
```

Destroy the buckets after verification to avoid leaving unused cloud
resources behind.

## Key Learnings

- `count` creates multiple instances from one resource block.
- `count.index` connects each instance to a list element.
- Resource addresses include an index when `count` is used.
- Terraform expressions must not be quoted when they should be evaluated.
- Resource references must use the exact declared local resource name.