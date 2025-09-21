# Terraform Backend Bootstrap

This repository contains a small Terraform configuration to bootstrap a remote backend for other Terraform projects.

What it creates
- An S3 bucket to store Terraform state (terraform.tfstate).
  - Versioning enabled to preserve previous states.
  - Server-side encryption (AES256) to protect state at rest.
- A DynamoDB table to enable state locking and prevent concurrent Terraform runs that could corrupt state.

Why use this
- Storing state remotely in S3 and enabling locking with DynamoDB is a recommended pattern for teams and CI systems.
- This module prepares the backing infrastructure once (or per environment) so other Terraform projects can configure their `backend "s3"` to point at the created resources.

Files
- `main.tf` — defines AWS provider, S3 bucket, versioning, encryption, and DynamoDB table.
- `variables.tf` — variables used by the module (region, bucket name, DynamoDB table name).

Quick start

1. Set up AWS credentials

Ensure your environment has AWS credentials available (environment variables, shared credentials file, or an IAM role if running on an EC2 instance/CI runner).

2. Edit variables or provide them on the command line

At minimum you must provide a globally unique `bucket_name`:

Example using CLI variables:

```bash
terraform init
terraform apply -var="bucket_name=myorg-terraform-state-prod" -var="aws_region=us-east-1"
```

Or create a `terraform.tfvars` file with:

```hcl
bucket_name = "myorg-terraform-state-prod"
aws_region  = "us-east-1"
# optional: dynamodb_table_name = "terraform-locks"
```

3. Create the backend resources

Run the usual Terraform workflow to create the S3 bucket and DynamoDB table:

```bash
terraform init
terraform apply -var="bucket_name=myorg-terraform-state-prod"
```

4. Configure another Terraform project to use the created backend

In your other Terraform project's root, configure the S3 backend. Example `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "myorg-terraform-state-prod"
    key            = "path/to/state/terraform.tfstate" # choose a key per project/environment
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

Then run in that project:

```bash
terraform init
# Terraform will detect the backend and initialize it. If you changed backend settings, re-run init.
```

Notes and troubleshooting

- Bucket name must be globally unique. If creation fails with a bucket name conflict, pick another name.
- If you get access denied errors, verify AWS credentials and IAM permissions for creating S3 buckets and DynamoDB tables.
- The S3 bucket is created without a public access block in this bootstrap. For production environments, consider adding `aws_s3_bucket_public_access_block` resource and appropriate bucket policies.
- If you share the same DynamoDB table for locks across multiple environments, ensure the lock keys (the `key` value in the S3 backend) are unique per workspace to avoid conflicts.

Security considerations

- Avoid checking in sensitive credentials. Use CI secrets or environment variables.
- Consider enabling server-side encryption with KMS for more control over keys (update `aws_s3_bucket_server_side_encryption_configuration` accordingly).

Next steps and improvements

- Add an optional KMS key and configure the S3 bucket to use SSE-KMS.
- Add lifecycle and retention rules for old state versions if desired.
- Add IAM policies/users/roles with least-privilege permissions to manage the backend resources.

License

MIT
