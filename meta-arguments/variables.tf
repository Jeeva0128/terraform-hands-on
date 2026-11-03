variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "practice-meta-argu-ments-jeeva"
}

variable "bucket_name_suffix" {
  description = "The number of S3 buckets to create"
  type        = list(string)
  default     = ["bucket-1", "bucket-2", "bucket-3", "bucket-4", "bucket-5"]

}