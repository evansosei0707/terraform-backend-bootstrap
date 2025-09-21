// Configure the AWS provider. This tells Terraform which region to operate in.
// The `aws_region` variable is set in `variables.tf` (default: us-east-1).
provider "aws" {
  region = var.aws_region
}

// S3 bucket that will hold the remote Terraform state file (e.g. terraform.tfstate).
// NOTE: S3 bucket names must be globally unique. Provide a unique value via
// the `bucket_name` variable when you run this module.
resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name

  // Helpful tag so the bucket is identifiable in the AWS console
  tags = {
    Name = "terraform-state-${var.bucket_name}"
  }
}

// Enable versioning on the S3 bucket. This is recommended for Terraform state
// so previous state files are retained and can be recovered if overwritten.
resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

// Enforce server-side encryption for objects stored in the bucket. We use
// AWS-managed S3 encryption (AES256). This helps protect the state file at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_bucket_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


// DynamoDB table used by Terraform to implement state locking. When using the
// S3 backend with locking enabled, Terraform will create a lock item in this
// table to prevent concurrent runs that could corrupt the state.
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST" // on-demand billing
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.dynamodb_table_name
  }
}

// Expose the created resources as outputs so other tooling or humans can
// easily discover the S3 bucket name and DynamoDB table name.
output "s3_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table" {
  value = aws_dynamodb_table.tf_locks.name
}
