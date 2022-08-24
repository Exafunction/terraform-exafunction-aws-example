#!/bin/bash
set -euxo pipefail

# Note: this script will not work if any of these Terraform modules haven't been applied at all.

# Get directory of this script
ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REMOTE_STATE_AWS_KEY="aws.tf"
REMOTE_STATE_KUBE_KEY="kube.tf"

# Get remote state output variables.
cd $ROOT_DIR/remote-state
REMOTE_STATE_REGION=$(terraform output -raw region)
REMOTE_STATE_BUCKET=$(terraform output -raw bucket)

# TODO(nick): add check for approval.

# Destroy kube Terraform module
cd $ROOT_DIR/kube
terraform init \
    -backend-config="region=$REMOTE_STATE_REGION" \
    -backend-config="bucket=$REMOTE_STATE_BUCKET" \
    -backend-config="key=$REMOTE_STATE_KUBE_KEY" \
    -reconfigure
terraform destroy \
    -var-file $ROOT_DIR/config.tfvars \
    -var="values_file_path=$ROOT_DIR/values.yaml" \
    -var="remote_state_config={\"bucket\":\"$REMOTE_STATE_BUCKET\",\"key\":\"$REMOTE_STATE_AWS_KEY\",\"region\":\"$REMOTE_STATE_REGION\"}" \
    -compact-warnings \
    -auto-approve

# Destroy aws Terraform module
cd $ROOT_DIR/aws
terraform init \
    -backend-config="region=$REMOTE_STATE_REGION" \
    -backend-config="bucket=$REMOTE_STATE_BUCKET" \
    -backend-config="key=$REMOTE_STATE_AWS_KEY" \
    -reconfigure
terraform destroy \
    -var-file $ROOT_DIR/config.tfvars \
    -compact-warnings \
    -auto-approve

# Destroy remote-state Terraform module
cd $ROOT_DIR/remote-state
terraform init \
    -reconfigure
terraform destroy \
    -var-file $ROOT_DIR/config.tfvars \
    -compact-warnings \
    -auto-approve
