locals {
  unique_suffix = var.unique_suffix == "" ? "" : "-${var.unique_suffix}"
  cluster_name  = "exafunction-cluster${local.unique_suffix}"
}

data "aws_availability_zones" "available" {}

module "exafunction_network" {
  source  = "Exafunction/exafunction-cloud/aws//modules/network"
  version = "0.1.1"

  vpc_cidr_block = var.vpc_cidr
  vpc_name       = "exafunction-vpc${local.unique_suffix}"
}

module "exafunction_cluster" {
  source  = "Exafunction/exafunction-cloud/aws//modules/cluster"
  version = "0.1.1"

  cluster_name = local.cluster_name
  vpc_id       = module.exafunction_network.vpc_id
  subnet_ids   = module.exafunction_network.private_subnets

  runner_pools = var.runner_pools

  instance_tags = var.instance_tags
}

module "exafunction_module_repo_backend" {
  source  = "Exafunction/exafunction-cloud/aws//modules/module_repo_backend"
  version = "0.1.1"

  exadeploy_id         = "exafunction${local.unique_suffix}"
  db_subnet_group_name = module.exafunction_network.database_subnet_group_name
  vpc_security_group_ids = [
    module.exafunction_cluster.cluster_primary_security_group_id,
    module.exafunction_cluster.cluster_security_group_id,
    module.exafunction_cluster.node_security_group_id,
  ]
}

data "aws_route_table" "main" {
  count = var.vpc_peering_config.enabled ? 1 : 0

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
  count = var.vpc_peering_config.enabled ? 1 : 0

  filter {
    name   = "association.subnet-id"
    values = var.vpc_peering_config.peer_subnet_ids
  }
}

locals {
  # TODO(nick): Fix case where if some of the peer subnets have explicit route table associations
  # and some do not, the main route table (used for subnets without explicit route table
  # association) will not be included.
  peer_route_table_ids = var.vpc_peering_config.enabled ? (length(one(data.aws_route_tables.peer).ids) > 0 ? one(data.aws_route_tables.peer).ids : [one(data.aws_route_table.main).id]) : []
}

module "exafunction_peering" {
  count   = var.vpc_peering_config.enabled ? 1 : 0
  version = "0.1.1"

  source               = "Exafunction/exafunction-cloud/aws//modules/peering"
  vpc_id               = module.exafunction_network.vpc_id
  route_table_ids      = module.exafunction_network.private_route_table_ids
  security_group_id    = module.exafunction_cluster.node_security_group_id
  peer_vpc_id          = var.vpc_peering_config.peer_vpc_id
  peer_route_table_ids = local.peer_route_table_ids
}
