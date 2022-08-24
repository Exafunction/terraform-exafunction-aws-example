# aws

This Terraform module is used to set up a new EKS cluster that can be integrated with existing infrastructure outside of EKS (or in an existing, separate EKS cluster). It is responsible for creating a new VPC, new EKS cluster, and optional VPC peering mechanism (along with associated routing and security group rules) between an existing VPC and the newly created VPC.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_exafunction"></a> [exafunction](#module\_exafunction) | https://storage.googleapis.com/exafunction-dist/terraform-exafunction-aws-29a260f.tar.gz//terraform-exafunction-aws-29a260f | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |
| <a name="module_vpc_peer"></a> [vpc\_peer](#module\_vpc\_peer) | ./modules/vpc_peer | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_route_table.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_route_tables.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_suffix"></a> [cluster\_suffix](#input\_cluster\_suffix) | Unique suffix to add to the cluster (and VPC). Useful if trying to spin up multiple Exafunction clusters. | `string` | `""` | no |
| <a name="input_gpu_node_config"></a> [gpu\_node\_config](#input\_gpu\_node\_config) | GPU node configuration. `gpu_ec2_instance_type` is the EC2 instance type to use for the GPU nodes. `min_gpu_nodes` and `max_gpu_nodes` define the minimum and maximum number of nodes in the GPU node pool. `accelerator_label` is the label of the GPU accelerator to use and should be determined by the accelerator type of `gpu_ec2_instance_type`. | <pre>object({<br>    gpu_ec2_instance_type = string<br>    min_gpu_nodes         = number<br>    max_gpu_nodes         = number<br>    accelerator_label     = string<br>  })</pre> | <pre>{<br>  "accelerator_label": "nvidia-tesla-t4",<br>  "gpu_ec2_instance_type": "g4dn.xlarge",<br>  "max_gpu_nodes": 10,<br>  "min_gpu_nodes": 1<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | Region for VPC and EKS. If using VPC peering, this should be the same as the region of the peered VPC. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR range for VPC. If using VPC peering, make sure this does not overlap with addresses in the peered VPC CIDR range. In most cases, this should be a /16 CIDR range. | `string` | n/a | yes |
| <a name="input_vpc_peering_config"></a> [vpc\_peering\_config](#input\_vpc\_peering\_config) | VPC peering connection configuration. `peer_vpc_id` is the ID of the VPC to peer with. `peer_subnet_ids` are the list of subnet IDs that are expected to send requests to the ExaDeploy cluster. | <pre>object({<br>    enabled         = bool<br>    peer_vpc_id     = string<br>    peer_subnet_ids = list(string)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_iam_user_access_key"></a> [cluster\_iam\_user\_access\_key](#output\_cluster\_iam\_user\_access\_key) | Access key for the cluster IAM user |
| <a name="output_cluster_iam_user_secret_key"></a> [cluster\_iam\_user\_secret\_key](#output\_cluster\_iam\_user\_secret\_key) | Secret key for the cluster IAM user |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the EKS cluster. |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | ID of the EKS cluster security group |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID of the EKS cluster additional security group |
| <a name="output_rds_address"></a> [rds\_address](#output\_rds\_address) | Address for the RDS instance |
| <a name="output_rds_password"></a> [rds\_password](#output\_rds\_password) | Password for the RDS instance |
| <a name="output_rds_port"></a> [rds\_port](#output\_rds\_port) | Port for the RDS instance |
| <a name="output_rds_username"></a> [rds\_username](#output\_rds\_username) | Username for the RDS instance |
| <a name="output_region"></a> [region](#output\_region) | Region of the EKS cluster. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | ID of the S3 bucket |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC. |
| <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id) | ID of the EKS workers security group |
<!-- END_TF_DOCS -->
