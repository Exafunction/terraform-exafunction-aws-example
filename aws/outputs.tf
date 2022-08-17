output "region" {
  description = "Region of the EKS cluster."
  value       = var.region
}

output "cluster_id" {
  description = "ID of the EKS cluster."
  value       = module.exafunction.cluster_id
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "cluster_primary_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = module.exafunction.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  description = "ID of the EKS cluster additional security group"
  value       = module.exafunction.cluster_security_group_id
}

output "worker_security_group_id" {
  description = "ID of the EKS workers security group"
  value       = module.exafunction.worker_security_group_id
}

output "cluster_iam_user_access_key" {
  description = "Access key for the cluster IAM user"
  sensitive   = true
  value       = module.exafunction.cluster_iam_user_access_key
}

output "cluster_iam_user_secret_key" {
  description = "Secret key for the cluster IAM user"
  sensitive   = true
  value       = module.exafunction.cluster_iam_user_secret_key
}

output "rds_address" {
  description = "Address for the RDS instance"
  value       = module.exafunction.rds_address
}

output "rds_username" {
  description = "Username for the RDS instance"
  value       = module.exafunction.rds_username
}

output "rds_port" {
  description = "Port for the RDS instance"
  value       = module.exafunction.rds_port
}

output "rds_password" {
  description = "Password for the RDS instance"
  sensitive   = true
  value       = module.exafunction.rds_password
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.exafunction.s3_bucket_id
}
