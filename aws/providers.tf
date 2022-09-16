provider "aws" {
  region = var.region

  default_tags {
    tags = var.aws_default_tags
  }
}
