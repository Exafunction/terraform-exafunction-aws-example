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
    condition     = can(regex("^[a-zA-Z0-9\\.\\-]{3,63}$", var.remote_state_config.bucket))
    error_message = "Invalid AWS bucket name format in `remote_state_config`."
  }

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.remote_state_config.region))
    error_message = "Invalid AWS region format in `remote_state_config`."
  }
}

variable "exadeploy_helm_chart_version" {
  description = "Version of the ExaDeploy Helm chart to install."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.exadeploy_helm_chart_version))
    error_message = "Invalid Helm chart version format."
  }
}

variable "api_key" {
  description = "API key used to identify the user to the Exafunction API."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.api_key))
    error_message = "Invalid API key format."
  }
}

variable "scheduler_image" {
  description = "Path to ExaDeploy scheduler image."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9.\\-_\\/@])+:([a-z0-9.-_])+$", var.scheduler_image))
    error_message = "Invalid ExaDeploy scheduler image path format."
  }
}

variable "module_repository_image" {
  description = "Path to ExaDeploy module repository image."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9.\\-_\\/@])+:([a-z0-9.-_])+$", var.module_repository_image))
    error_message = "Invalid ExaDeploy module repository image path format."
  }
}

variable "runner_image" {
  description = "Path to ExaDeploy runner image."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9.\\-_\\/@])+:([a-z0-9.-_])+$", var.runner_image))
    error_message = "Invalid ExaDeploy runner image path format."
  }
}

variable "values_file_path" {
  description = "Path to values YAML file to pass to exafunction-cluster Helm chart. Format should match values.yaml.example."
  type        = string
  default     = null
}
