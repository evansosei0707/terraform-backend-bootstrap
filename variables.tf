// AWS region where the bootstrap resources will be created. Change this to
// match the region you want to host your Terraform backend resources.
// Example: "us-west-2", "eu-central-1"
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

// The S3 bucket name for storing Terraform state. Bucket names must be
// globally unique across all AWS accounts and regions. A common pattern is
// to include your org name and environment, for example:
//   "myorg-terraform-state-prod"
// No default is provided so the caller must set a unique name.
variable "bucket_name" {
  description = "Unique S3 bucket name for terraform state (must be globally unique)"
  type        = string
}

// DynamoDB table used for Terraform state locking. Terraform will create a
// lock item in this table when performing operations that modify state.
// You may change the name if you have naming conventions, but keep it
// consistent across projects that share the same locking table.
variable "dynamodb_table_name" {
  description = "DynamoDB table name for terraform state locking"
  type        = string
  default     = "terraform-locks"
}
