resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket11-jeevanandan"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "example2" {
  bucket = "my-tf-test-bucket12-jeevanandan"

  tags = {
    Name        = "My updated bucket"
    Environment = "Dev"
  }
}
