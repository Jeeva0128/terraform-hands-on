output "formatted_project_name" {
  value = local.formatted_project_name
}

output "project_prefix" {
  value = local.project_prefix
}

output "uppercase_project" {
  value = local.uppercase_project
}

output "merged_tags" {
  value = local.all_tags
}

output "parsed_ports" {
  value = local.port_list
}

output "total_ports" {
  value = local.total_ports
}

output "additional_ports" {
  value = local.additional_ports
}

output "security_group_rules" {
  value = local.security_group_rules
}

output "selected_instance_size" {
  value = local.selected_instance_size
}

output "numeric_results" {
  value = {
    largest  = local.largest_port
    smallest = local.smallest_port
    absolute = local.absolute_value
  }
}