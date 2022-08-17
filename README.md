# terraform-exafunction-aws-example

## Overview
This repository acts as a quickstart to setup ExaDeploy for AWS. It is specifically designed for users that want to spin up an ExaDeploy system in a new EKS cluster and offload remote GPU computations from applications running in either existing AWS infrastructure (such as on EC2 instances or in a different EKS cluster) or within the newly created EKS cluster.

This installation is responsible for creating a new VPC, new EKS cluster, ExaDeploy system in that cluster, and optional VPC peering mechanism (along with associated routing and security group rules) between an existing VPC and the newly created VPC.

Users should clone this repository locally and follow the steps below to setup ExaDeploy.

## Prerequisites
This repository is dependent on Terraform and Helm, which can be installed according to these directions:
* [Terraform](https://www.terraform.io/downloads)
* [Helm](https://helm.sh/docs/intro/install/)

After installation you should be able to run both `terraform` and `helm` as commands in the command line (these commands will show documentation when run without arguments).

## Configuration
There are a few configuration files that must be modified prior to running this installation. If you will be running applications in existing AWS infrastructure outside of the newly created EKS cluster, you will need to configure VPC peering (see below).

### [`config.tfvars`](/config.tfvars)
This file contains the configuration for the Terraform modules. Users should modify:
* `region`: The AWS region for the new VPC and EKS cluster.
    * If VPC peering, this should be the same region as your existing VPC to avoid cross-regional egress charges due to sending data between the VPCs.
* `vpc_cidr`: The CIDR block for the new VPC to create.
    * If VPC peering, this CIDR range **cannot** overlap with the CIDR range of your existing VPC to peer with.
    * We recommend choosing a /16 range from the 10.0.0.0/8 private IP range, such as 10.255.0.0/16.
* `vpc_peering_config`: The configuration for VPC peering.
    * `enabled`: Whether to enable VPC peering.
    * `peer_vpc_id`: The ID of the VPC to peer with.
        * This should be the ID for the VPC where the applications will run.
    * `peer_subnet_ids`: The IDs of the subnets to peer with.
        * This should be the list of IDs for all subnets running applications that will interact with ExaDeploy.
        * The set of subnet IDs can be easily updated later if you end up running applications in a new subnet.
* `api_key`: The API key used to identify your company to Exafunction.
    * This should be provided by Exafunction.
* `exafunction_chart_version`: The version of the Exafunction Helm chart to install.
    * This should be in the release provided by Exafunction.

### [`values.yaml`](/values.yaml)
Users should modify this file to provide the image names for ExaDeploy system components. These image names should be in the release provided by Exafunction.

### [`config.s3.tfbackend`](/config.s3.tfbackend)
This file contains the configuration for the S3 backend used to manage [Terraform state](https://www.terraform.io/language/state). Reasonable defaults are provided and users can modify as needed. Note that this S3 bucket **should not** already exist as its creation and management will be handled by Terraform.

## Create
After finishing configuration, run
```bash
./create.sh
```
from the repository's root directory. It may take some time (up to 30 minutes) to finish applying as it needs to spin up and configure many new AWS resources.

## Destroy
Run
```bash
./destroy.sh
```
from the repoistory's root directory. This will delete all resources created by the installation including the ExaDeploy system, VPC peering connection, EKS cluster, and VPC.

## Running applications with ExaDeploy
For instructions on how to write and run applications that offload GPU computations to ExaDeploy, see our Quickstart Guide.

Applications running on external AWS infrastructure (i.e. not within the ExaDeploy cluster) will need to use the load balancer addresses for the ExaDeploy module repository and scheduler services.

To get these addresses, run these commands from the repository's root directory:

### Update Local Kubeconfig
```bash
aws eks update-kubeconfig \
    --region $(terraform -chdir=aws output region | tr -d '"') \
    --name $(terraform -chdir=aws output cluster_id | tr -d '"')
```

### Module Repository
```bash
kubectl get service module-repository-service \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}'
```

### Scheduler
```bash
kubectl get service scheduler-service \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}'
```

Both should return addresses in the format of `internal-<elb_name>-<digits>.<region>.elb.amazonaws.com`.
