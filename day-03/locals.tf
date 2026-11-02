locals {
  instance_id = aws_instance.my_instance.id
}
locals  {
  arn = aws_instance.my_instance.arn
}
locals  {
  private_ip = aws_instance.my_instance.private_ip
}
locals  {
  public_ip = aws_instance.my_instance.public_ip
}