variable "region" {
  description = "Region for S3 bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Invalid AWS region format."
  }
}

variable "remote_state_bucket_suffix" {
  description = "Optional suffix for the S3 bucket to use for storing terraform state."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\.\\-]{0,33}$", var.remote_state_bucket_suffix))
    error_message = "Invalid AWS bucket suffix format."
  }
}
