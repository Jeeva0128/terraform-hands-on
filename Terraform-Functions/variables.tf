variable "project_name" {
  type    = string
  default = "Project ALPHA Storage"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "allowed_ports" {
  type    = string
  default = "80,443,8080,3306"
}

variable "default_tags" {
  type = map(string)

  default = {
    Company   = "TechCorp"
    ManagedBy = "Terraform"
  }
}

variable "environment_tags" {
  type = map(string)

  default = {
    CostCenter  = "CC-101"
    Environment = "dev"
  }
}