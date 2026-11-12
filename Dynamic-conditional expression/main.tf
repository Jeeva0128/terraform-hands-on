resource "aws_security_group" "terra-handson-sg" {
  name        = "terra-handson"
  description = "Security group for Terraform hands-on"
  vpc_id      = "vpc-0e7f3b8c9d1a2b3c4" # Replace with your VPC ID
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

}