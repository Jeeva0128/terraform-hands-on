resource "aws_instance" "terra-instance" {
    ami = var.ami_ec2
    instance_type = var.instance_type[0]
    cpu_options  {
        core_count = var.cpu_core_count["core_count"]
        threads_per_core = var.cpu_core_count["threads_per_core"]
    }
}