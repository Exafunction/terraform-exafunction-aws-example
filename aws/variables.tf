variable "cluster_suffix" {
  description = "Unique suffix to add to the cluster (and VPC). Useful if trying to spin up multiple Exafunction clusters."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]*$", var.cluster_suffix))
    error_message = "Invalid cluster suffix format."
  }
}

variable "gpu_node_config" {
  description = "GPU node configuration. `gpu_ec2_instance_type` is the EC2 instance type to use for the GPU nodes. `min_gpu_nodes` and `max_gpu_nodes` define the minimum and maximum number of nodes in the GPU node pool. `accelerator_label` is the label of the GPU accelerator to use and should be determined by the accelerator type of `gpu_ec2_instance_type`."
  type = object({
    gpu_ec2_instance_type = string
    min_gpu_nodes         = number
    max_gpu_nodes         = number
    accelerator_label     = string
  })
  default = {
    gpu_ec2_instance_type = "g4dn.xlarge"
    min_gpu_nodes         = 1
    max_gpu_nodes         = 10
    accelerator_label     = "nvidia-tesla-t4"
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
