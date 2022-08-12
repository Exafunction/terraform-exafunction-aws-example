variable "vpc_id" {
  description = "ID of the Exafunction VPC."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets to use for the Exafunction VPC."
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block range for the Exafunction VPC."
  type        = string
}

variable "cluster_primary_security_group_id" {
  description = "ID of the primary security group for the Exafunction cluster."
  type        = string
}

variable "peer_vpc_id" {
  description = "ID of the peer VPC."
  type        = string
}

variable "peer_route_table_ids" {
  description = "List of route table IDs for the peer VPC."
  type        = list(string)
}
