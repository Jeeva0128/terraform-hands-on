variable "region"{
    type = list(string)
    default = ["ap-south-1", "ap-south-2"]
}
variable "instance_type" {
    type = list(string)
    default = ["t2.micro", "t2.small","t3.micro"]
}

variable environment {
    type = list(string)
    default = ["dev", "prod"]
}
variable project_name {
    type = string
    default = "Terraform demo"
}