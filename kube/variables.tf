variable "api_key" {
  description = "API key used to identify the user to the Exafunction API."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.api_key))
    error_message = "Invalid API key format."
  }
}

variable "region" {
  description = "Region for existing EKS cluster."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Invalid AWS region format."
  }
}

variable "remote_state_config" {
  description = "Configuration parameters for the cluster Terraform's remote state (S3)."
  type = object({
    bucket = string
    key    = string
    region = string
  })

  validation {
    condition     = can(regex("^[a-zA-Z\\.\\-]{3,63}$", var.remote_state_config.bucket))
    error_message = "Invalid AWS bucket name format in `remote_state_config`."
  }

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.remote_state_config.region))
    error_message = "Invalid AWS region format in `remote_state_config`."
  }
}

variable "values_file_path" {
  description = "Path to values YAML file to pass to exafunction-cluster Helm chart. Format should match values.yaml.example."
  type        = string
}
