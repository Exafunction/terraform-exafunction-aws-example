output "region" {
  description = "Region for the S3 bucket to use for storing Terraform state."
  value       = aws_s3_bucket.terraform_state.region
}

output "bucket" {
  description = "Name of the S3 bucket to use for storing Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}
