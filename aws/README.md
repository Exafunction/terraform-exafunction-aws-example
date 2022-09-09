# aws

This Terraform module is used to set up a new EKS cluster that can be integrated with existing infrastructure outside of EKS (or in an existing, separate EKS cluster). It is responsible for creating a new VPC, new EKS cluster, and optional VPC peering mechanism (along with associated routing and security group rules) between an existing VPC and the newly created VPC.

<!-- BEGIN_TF_DOCS -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_exafunction_cluster"></a> [exafunction\_cluster](#module\_exafunction\_cluster) | Exafunction/exafunction-cloud/aws//modules/cluster | 0.1.0 |
| <a name="module_exafunction_module_repo_backend"></a> [exafunction\_module\_repo\_backend](#module\_exafunction\_module\_repo\_backend) | Exafunction/exafunction-cloud/aws//modules/module_repo_backend | 0.1.0 |
| <a name="module_exafunction_network"></a> [exafunction\_network](#module\_exafunction\_network) | Exafunction/exafunction-cloud/aws//modules/network | 0.1.0 |
| <a name="module_exafunction_peering"></a> [exafunction\_peering](#module\_exafunction\_peering) | Exafunction/exafunction-cloud/aws//modules/peering | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_route_table.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_route_tables.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_tags"></a> [instance\_tags](#input\_instance\_tags) | Tags to apply to all EC2 instances managed by the cluster. | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for VPC and EKS. If using VPC peering, this should be the same as the region of the peered VPC. | `string` | n/a | yes |
| <a name="input_runner_pools"></a> [runner\_pools](#input\_runner\_pools) | Configuration parameters for Exafunction runner node pools. | <pre>list(object({<br>    # Node group suffix.<br>    suffix = string<br>    # One of (cpu, gpu).<br>    node_instance_category = string<br>    # One of (ON_DEMAND, SPOT).<br>    capacity_type = string<br>    # Instance type.<br>    node_instance_type = string<br>    # Disk size.<br>    disk_size = number<br>    # Minimum number of nodes.<br>    min_size = number<br>    # Maximum number of nodes.<br>    max_size = number<br>    # Value for k8s.amazonaws.com/accelerator.<br>    accelerator_label = string<br>    # Additional taints.<br>    additional_taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>    # Additional labels.<br>    additional_labels = map(string)<br>  }))</pre> | <pre>[<br>  {<br>    "accelerator_label": "nvidia-tesla-t4",<br>    "additional_labels": {},<br>    "additional_taints": [],<br>    "capacity_type": "ON_DEMAND",<br>    "disk_size": 100,<br>    "max_size": 10,<br>    "min_size": 1,<br>    "node_instance_category": "gpu",<br>    "node_instance_type": "g4dn.xlarge",<br>    "suffix": "gpu"<br>  }<br>]</pre> | no |
| <a name="input_unique_suffix"></a> [unique\_suffix](#input\_unique\_suffix) | Unique suffix to add to the AWS resources. Useful if trying to spin up multiple Exafunction clusters. | `string` | `""` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR range for VPC. If using VPC peering, make sure this does not overlap with addresses in the peered VPC CIDR range. In most cases, this should be a /16 CIDR range. | `string` | n/a | yes |
| <a name="input_vpc_peering_config"></a> [vpc\_peering\_config](#input\_vpc\_peering\_config) | VPC peering connection configuration. `peer_vpc_id` is the ID of the VPC to peer with. `peer_subnet_ids` are the list of subnet IDs that are expected to send requests to the ExaDeploy cluster. | <pre>object({<br>    enabled         = bool<br>    peer_vpc_id     = string<br>    peer_subnet_ids = list(string)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster.. |
| <a name="output_exafunction_cluster"></a> [exafunction\_cluster](#output\_exafunction\_cluster) | Exafunction cluster module. |
| <a name="output_exafunction_module_repo_backend"></a> [exafunction\_module\_repo\_backend](#output\_exafunction\_module\_repo\_backend) | Exafunction module repository backend module. |
| <a name="output_exafunction_network"></a> [exafunction\_network](#output\_exafunction\_network) | Exafunction network module. |
| <a name="output_exafunction_peering"></a> [exafunction\_peering](#output\_exafunction\_peering) | Exafunction peering module. |
| <a name="output_region"></a> [region](#output\_region) | Region of the EKS cluster.. |
<!-- END_TF_DOCS -->
