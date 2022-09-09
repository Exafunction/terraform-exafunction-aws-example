# kube

This Terraform module is used to set up the ExaDeploy system inside an existing EKS cluster (created using the `aws` module).

After deployment, ExaDeloy clients will be able to communicate with the ExaDeploy system and offload remote GPU computation to ExaDeploy.

<!-- BEGIN_TF_DOCS -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_exafunction-kube"></a> [exafunction-kube](#module\_exafunction-kube) | Exafunction/exafunction-kube/aws | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [terraform_remote_state.cloud](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | API key used to identify the user to the Exafunction API. | `string` | n/a | yes |
| <a name="input_exadeploy_helm_chart_version"></a> [exadeploy\_helm\_chart\_version](#input\_exadeploy\_helm\_chart\_version) | Version of the ExaDeploy Helm chart to install. | `string` | n/a | yes |
| <a name="input_module_repository_image"></a> [module\_repository\_image](#input\_module\_repository\_image) | Path to ExaDeploy module repository image. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for existing EKS cluster. | `string` | n/a | yes |
| <a name="input_remote_state_config"></a> [remote\_state\_config](#input\_remote\_state\_config) | Configuration parameters for the cluster Terraform's remote state (S3). | <pre>object({<br>    bucket = string<br>    key    = string<br>    region = string<br>  })</pre> | n/a | yes |
| <a name="input_runner_image"></a> [runner\_image](#input\_runner\_image) | Path to ExaDeploy runner image. | `string` | n/a | yes |
| <a name="input_scheduler_image"></a> [scheduler\_image](#input\_scheduler\_image) | Path to ExaDeploy scheduler image. | `string` | n/a | yes |
| <a name="input_values_file_path"></a> [values\_file\_path](#input\_values\_file\_path) | Path to values YAML file to pass to exafunction-cluster Helm chart. Format should match values.yaml.example. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
