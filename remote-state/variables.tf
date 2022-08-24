variable "region" {
  description = "Region for S3 bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Invalid AWS region format."
  }
}

variable "bucket" {
  description = "Name of the S3 bucket to use for storing terraform state."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\.\\-]{3,63}$", var.bucket))
    error_message = "Invalid AWS bucket name format."
  }
}
