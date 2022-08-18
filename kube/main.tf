module "exafunction_kube" {
  source              = "https://storage.googleapis.com/exafunction-dist/terraform-exafunction-kube-619f94c.tar.gz//terraform-exafunction-kube-619f94c"
  values_yaml         = var.values_file_path
  api_key             = var.api_key
  remote_state_config = var.remote_state_config
  chart_version       = var.exafunction_chart_version
}
