module "exafunction_kube" {
  source              = "https://storage.googleapis.com/exafunction-dist/terraform-exafunction-kube-fd1071f.tar.gz//terraform-exafunction-kube-fd1071f"
  values_yaml         = var.values_file_path
  api_key             = var.api_key
  remote_state_config = var.remote_state_config
}
