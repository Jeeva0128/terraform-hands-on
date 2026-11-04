variable "ami_ec2" {
    type = string
    default = "ami-0912f71e06545ad88"
}

variable "instance_type" {
    type = list(string)
    default = ["t2.large","t2.micro","t2.small"]
}

variable "cpu_core_count" {
    type = map(number)
    default = {
        core_count = 1
        threads_per_core = 1
    }
}