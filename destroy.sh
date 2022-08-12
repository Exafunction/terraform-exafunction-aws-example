#!/bin/bash
set -euxo pipefail

# Note: this script will not work if any of these Terraform modules haven't been applied at all.

# Get directory of this script
ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TERRAFORM_EXAFUNCTION_AWS_KEY="aws.tf"
TERRAFORM_EXAFUNCTION_KUBE_KEY="kube.tf"

# Get shell variables from config.s3.tfbackend
source $ROOT_DIR/config.s3.tfbackend

# TODO(nick): add check for approval.

# Destroy kube Terraform module
cd $ROOT_DIR/kube
terraform init \
    -backend-config=$ROOT_DIR/config.s3.tfbackend \
    -backend-config="key=$TERRAFORM_EXAFUNCTION_KUBE_KEY"
terraform destroy \
    -var-file $ROOT_DIR/config.tfvars \
    -var="values_file_path=$ROOT_DIR/values.yaml" \
    -var="remote_state_config={\"bucket\":\"$bucket\",\"key\":\"$TERRAFORM_EXAFUNCTION_AWS_KEY\",\"region\":\"$region\"}" \
    -compact-warnings \
    -auto-approve

# Destroy aws Terraform module
cd $ROOT_DIR/aws
terraform init \
    -backend-config=$ROOT_DIR/config.s3.tfbackend \
    -backend-config="key=$TERRAFORM_EXAFUNCTION_AWS_KEY"
terraform destroy \
    -var-file $ROOT_DIR/config.tfvars \
    -compact-warnings \
    -auto-approve

# Destroy remote-state Terraform module
cd $ROOT_DIR/remote-state
terraform init
terraform destroy \
    -var-file=$ROOT_DIR/config.s3.tfbackend \
    -auto-approve
