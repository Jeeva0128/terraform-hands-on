resource "aws_instance" "my_instance" {
  ami           = "ami-0912f71e06545ad88"
  instance_type = var.instance_type[0]

  tags = {
    Name        = var.project_name
    Environment = var.environment[0]
 
  }
}
