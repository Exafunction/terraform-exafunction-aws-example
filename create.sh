#!/bin/bash
set -euxo pipefail

# Get directory of this script
ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REMOTE_STATE_AWS_KEY="aws.tf"
REMOTE_STATE_KUBE_KEY="kube.tf"

# Apply remote-state Terraform module
cd $ROOT_DIR/remote-state
terraform init \
    -reconfigure
terraform apply \
    -var-file $ROOT_DIR/config.tfvars \
    -compact-warnings \
    -auto-approve

# Get remote state output variables.
REMOTE_STATE_REGION=$(terraform output -raw region)
REMOTE_STATE_BUCKET=$(terraform output -raw bucket)

# Apply aws Terraform module
cd $ROOT_DIR/aws
terraform init \
    -backend-config="region=$REMOTE_STATE_REGION" \
    -backend-config="bucket=$REMOTE_STATE_BUCKET" \
    -backend-config="key=$REMOTE_STATE_AWS_KEY" \
    -reconfigure
terraform apply \
    -var-file $ROOT_DIR/config.tfvars \
    -compact-warnings \
    -auto-approve

# Apply kube Terraform module
cd $ROOT_DIR/kube
terraform init \
    -backend-config="region=$REMOTE_STATE_REGION" \
    -backend-config="bucket=$REMOTE_STATE_BUCKET" \
    -backend-config="key=$REMOTE_STATE_KUBE_KEY" \
    -reconfigure
terraform apply \
    -var-file $ROOT_DIR/config.tfvars \
    -var="values_file_path=$ROOT_DIR/values.yaml" \
    -var="remote_state_config={\"bucket\":\"$REMOTE_STATE_BUCKET\",\"key\":\"$REMOTE_STATE_AWS_KEY\",\"region\":\"$REMOTE_STATE_REGION\"}" \
    -compact-warnings \
    -auto-approve
