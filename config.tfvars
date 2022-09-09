# Region and CIDR range for the Exafunction VPC.
region   = "us-west-1"
vpc_cidr = "10.255.0.0/16"

# VPC peering information for existing VPC to peer with.
vpc_peering_config = {
  enabled         = true
  peer_vpc_id     = "vpc-<VPC_ID>"
  peer_subnet_ids = ["subnet-<SUBNET_ID>"]
}

# Runner pool configuration.
runner_pools = [{
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

# API key used to identify the company to Exafunction.
api_key = "<API_KEY>"

# ExaDeploy component images.
scheduler_image         = "433863713167.dkr.ecr.us-east-2.amazonaws.com/exafunction/scheduler:<SCHEDULER_IMAGE_TAG>"
module_repository_image = "433863713167.dkr.ecr.us-east-2.amazonaws.com/exafunction/module_repository:<MODULE_REPOSITORY_IMAGE_TAG>"
runner_image            = "433863713167.dkr.ecr.us-east-2.amazonaws.com/exafunction/runner@sha256:<RUNNER_IMAGE_SHA>"

# ExaDeploy Helm Chart version.
exadeploy_helm_chart_version = "<CHART_VERSION>"
