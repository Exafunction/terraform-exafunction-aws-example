variable "unique_suffix" {
  description = "Unique suffix to add to the AWS resources. Useful if trying to spin up multiple Exafunction clusters."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]*$", var.unique_suffix))
    error_message = "Invalid unique suffix format."
  }
}

variable "runner_pools" {
  description = "Configuration parameters for Exafunction runner node pools."
  type = list(object({
    # Node group suffix.
    suffix = string
    # One of (cpu, gpu).
    node_instance_category = string
    # One of (ON_DEMAND, SPOT).
    capacity_type = string
    # Instance type.
    node_instance_type = string
    # Disk size.
    disk_size = number
    # Minimum number of nodes.
    min_size = number
    # Maximum number of nodes.
    max_size = number
    # Value for k8s.amazonaws.com/accelerator.
    accelerator_label = string
    # Additional taints.
    additional_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    # Additional labels.
    additional_labels = map(string)
  }))
  default = [{
    suffix                 = "gpu"
    node_instance_category = "gpu"
    capacity_type          = "ON_DEMAND"
    node_instance_type     = "g4dn.xlarge"
    disk_size              = 100
    min_size               = 1
    max_size               = 10
    accelerator_label      = "nvidia-tesla-t4"
    additional_taints      = []
    additional_labels      = {}
  }]
  validation {
    condition = alltrue([
      for runner_pool in var.runner_pools : contains(["cpu", "gpu"], runner_pool.node_instance_category)
    ])
    error_message = "Node instance category be one of [cpu, gpu]."
  }
  validation {
    condition = alltrue([
      for runner_pool in var.runner_pools : contains(["ON_DEMAND", "SPOT"], runner_pool.capacity_type)
    ])
    error_message = "Capacity type be one of [ON_DEMAND, SPOT]."
  }
}

variable "region" {
  description = "Region for VPC and EKS. If using VPC peering, this should be the same as the region of the peered VPC."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Invalid AWS region format."
  }
}

variable "vpc_cidr" {
  description = "CIDR range for VPC. If using VPC peering, make sure this does not overlap with addresses in the peered VPC CIDR range. In most cases, this should be a /16 CIDR range."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}\\/[0-9]{1,2}$", var.vpc_cidr))
    error_message = "Invalid VPC CIDR range format."
  }
}

variable "vpc_peering_config" {
  description = "VPC peering connection configuration. `peer_vpc_id` is the ID of the VPC to peer with. `peer_subnet_ids` are the list of subnet IDs that are expected to send requests to the ExaDeploy cluster."
  type = object({
    enabled         = bool
    peer_vpc_id     = string
    peer_subnet_ids = list(string)
  })

  validation {
    condition     = !var.vpc_peering_config.enabled || (length(var.vpc_peering_config.peer_vpc_id) > 0 && length(var.vpc_peering_config.peer_subnet_ids) > 0)
    error_message = "`peer_vpc_id` and `peer_subnet_ids` are required when VPC peering is enabled."
  }
}

variable "aws_default_tags" {
  description = "Tags to apply to all AWS resources."
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Tags to apply to all EC2 instances managed by the cluster."
  type        = map(string)
  default     = {}
}

variable "autoscaling_group_tags" {
  description = "Tags to apply to all autoscaling groups managed by the cluster. These tags will not be propagated to the EC2 instances."
  type        = map(string)
  default     = {}
}
