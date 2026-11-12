locals {
  # String functions
  formatted_project_name = lower(
    replace(trimspace(var.project_name), " ", "-")
  )

  project_prefix = substr(
    local.formatted_project_name, 0, 7
  )

  uppercase_project = upper(var.project_name)

  # Collection functions
  all_tags = merge(
    var.default_tags,
    var.environment_tags
  )

  port_list = split(",", var.allowed_ports)

  total_ports = length(local.port_list)

  additional_ports = concat(
    local.port_list,
    ["9090", "3000"]
  )

  # Generate security group rule data
  security_group_rules = {
    for port in local.port_list :
    port => {
      port_number = tonumber(port)
      protocol    = "tcp"
      description = "Allow TCP port ${port}"
    }
  }

  # Lookup function
  instance_sizes = {
    dev     = "t2.micro"
    staging = "t2.small"
    prod    = "t3.large"
  }

  selected_instance_size = lookup(
    local.instance_sizes,
    var.environment,
    "t2.micro"
  )

  # Numeric functions
  largest_port  = max(80, 443, 8080)
  smallest_port = min(80, 443, 8080)
  absolute_value = abs(-25)
}