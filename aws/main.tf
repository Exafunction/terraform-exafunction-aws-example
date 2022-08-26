locals {
  cluster_suffix = var.cluster_suffix == "" ? "" : "-${var.cluster_suffix}"
  cluster_name   = "exafunction-cluster${local.cluster_suffix}"
}

data "aws_availability_zones" "available" {}

# Create VPC.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = "exafunction-vpc${local.cluster_suffix}"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2), cidrsubnet(var.vpc_cidr, 8, 3)]
  public_subnets       = [cidrsubnet(var.vpc_cidr, 8, 4), cidrsubnet(var.vpc_cidr, 8, 5), cidrsubnet(var.vpc_cidr, 8, 6)]
  database_subnets     = [cidrsubnet(var.vpc_cidr, 8, 7), cidrsubnet(var.vpc_cidr, 8, 8), cidrsubnet(var.vpc_cidr, 8, 9)]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# Create EKS cluster.
module "exafunction" {
  source       = "https://storage.googleapis.com/exafunction-dist/terraform-exafunction-aws-02816cc.tar.gz//terraform-exafunction-aws-02816cc"
  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.private_subnets
  runner_pools = [{
    suffix                 = "gpu"
    node_instance_category = "gpu"
    node_instance_type     = var.gpu_node_config.gpu_ec2_instance_type
    min_capacity           = var.gpu_node_config.min_gpu_nodes
    max_capacity           = var.gpu_node_config.max_gpu_nodes
    accelerator_label      = var.gpu_node_config.accelerator_label
  }]
}

# Enable inbound traffic from within the VPC (including instances outside the cluster).
resource "aws_security_group_rule" "exafunction_ingress_in_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = module.exafunction.cluster_primary_security_group_id
}

data "aws_route_table" "main" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_peering_config.peer_vpc_id]
  }
  filter {
    name   = "association.main"
    values = [true]
  }
}

data "aws_route_tables" "peer" {
  filter {
    name   = "association.subnet-id"
    values = var.vpc_peering_config.peer_subnet_ids
  }
}

locals {
  # TODO(nick): Fix bug where if some of the peer subnets have explicit route table associations and
  # some do not, the main route table (used for subnets without explicit route table association)
  # will not be included.
  peer_route_table_ids = length(data.aws_route_tables.peer.ids) > 0 ? data.aws_route_tables.peer.ids : [data.aws_route_table.main.id]
}

module "vpc_peer" {
  count = var.vpc_peering_config.enabled ? 1 : 0
  depends_on = [
    module.vpc,
    module.exafunction,
  ]
  source                            = "./modules/vpc_peer"
  vpc_id                            = module.vpc.vpc_id
  private_subnets                   = module.vpc.private_subnets
  vpc_cidr_block                    = module.vpc.vpc_cidr_block
  cluster_primary_security_group_id = module.exafunction.cluster_primary_security_group_id
  peer_vpc_id                       = var.vpc_peering_config.peer_vpc_id
  peer_route_table_ids              = local.peer_route_table_ids
}
