variable "region" {
  description = "Region for S3 bucket"
  type        = string
}

variable "bucket" {
  description = "Name of the S3 bucket to use for storing terraform state."
  type        = string
}
