resource "aws_s3_bucket" "my_bucket" {
    bucket = "${var.bucket_name}-${var.bucket_name_suffix[count.index]}"
    count = length(var.bucket_name_suffix)
    region = "ap-south-1"


}