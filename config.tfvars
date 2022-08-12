# Region and CIDR range for the Exafunction VPC.
region   = "us-west-1"
vpc_cidr = "10.255.0.0/16"

# VPC peering information for existing VPC to peer with.
vpc_peering_config = {
  enabled         = true
  peer_vpc_id     = "vpc-<VPC_ID>"
  peer_subnet_ids = ["subnet-<SUBNET_ID>"]
}

# API key used to identify the company to Exafunction.
api_key = "<API_KEY>"
