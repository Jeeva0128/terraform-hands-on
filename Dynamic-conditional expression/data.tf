# 1. Retrieve all VPC IDs in the current region
data "aws_vpcs" "all" {}

# 2. Fetch full details (tags, CIDR, etc.) for each VPC ID found
data "aws_vpc" "details" {
  for_each = toset(data.aws_vpcs.all.ids)
  id       = each.value
}

# 3. Print the details to your screen
output "existing_vpcs" {
  value = {
    for id, vpc in data.aws_vpc.details : id => {
      cidr_block = vpc.cidr_block
      is_default = vpc.default
      tags       = vpc.tags
    }
  }
}
