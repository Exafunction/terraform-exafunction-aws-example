# Create VPC peering connection.
data "aws_vpc" "peer_vpc" {
  id = var.peer_vpc_id
}

resource "aws_vpc_peering_connection" "exafunction" {
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = data.aws_vpc.peer_vpc.owner_id
  auto_accept   = true
  tags = {
    "Name" = "exafunction-vpc-peering-connection"
  }
}

# Create route table routes.
data "aws_route_tables" "exafunction" {
  filter {
    name   = "association.subnet-id"
    values = var.private_subnets
  }
}

resource "aws_route" "exafunction" {
  depends_on = [
    aws_vpc_peering_connection.exafunction,
  ]
  # This assumes there will only be one route table associated with the private subnets in order to
  # get around the resource count being undeterminable at plan time.
  route_table_id            = one(data.aws_route_tables.exafunction.ids)
  destination_cidr_block    = data.aws_vpc.peer_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.exafunction.id
}

resource "aws_route" "peer" {
  count = length(var.peer_route_table_ids)
  depends_on = [
    aws_vpc_peering_connection.exafunction,
  ]
  route_table_id            = var.peer_route_table_ids[count.index]
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.exafunction.id
}

# Create security group rule.
resource "aws_security_group_rule" "exafunction_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  # TODO(nick): Change to use `source_security_group_id`.
  cidr_blocks       = [data.aws_vpc.peer_vpc.cidr_block]
  security_group_id = var.cluster_primary_security_group_id
}
