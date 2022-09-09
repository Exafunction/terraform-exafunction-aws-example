provider "aws" {
  region = var.region
}

data "terraform_remote_state" "cloud" {
  backend = "s3"
  config = {
    bucket = var.remote_state_config.bucket
    key    = var.remote_state_config.key
    region = var.remote_state_config.region
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.cloud.outputs.exafunction_cluster.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.cloud.outputs.exafunction_cluster.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
