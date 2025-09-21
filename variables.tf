variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Unique S3 bucket name for terraform state (must be globally unique)"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for terraform state locking"
  type        = string
  default     = "terraform-locks"
}
