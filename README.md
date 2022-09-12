# terraform-exafunction-aws-example

![Banner](images/banner.png)

## Overview
This repository acts as a way to quickly set up ExaDeploy for AWS. It is specifically designed for users that want to create an ExaDeploy system in a new EKS cluster and offload remote GPU computations from applications running in either existing AWS infrastructure (such as on EC2 instances or in a different EKS cluster) or within the newly created EKS cluster.

This installation is responsible for creating a new VPC, new EKS cluster, ExaDeploy system in that cluster, and optional VPC peering mechanism (along with associated routing and security group rules) between an existing VPC and the newly created VPC.

Users should clone this repository locally and follow the steps below to setup ExaDeploy.

For advanced users or users that want to integrate this setup into their existing Terraform code, we recommend directly using our Terraform modules (which are called internally in this repository). See [exafunction-cloud](https://registry.terraform.io/modules/Exafunction/exafunction-cloud/aws) and [exafunction-kube](https://registry.terraform.io/modules/Exafunction/exafunction-kube/aws) in the [Terraform Registry](https://registry.terraform.io/) for module reference.

## Prerequisites
This repository is dependent on Terraform, Helm, kubectl, and AWS CLI which can be installed according to these directions:
* [Terraform](https://www.terraform.io/downloads)
* [Helm](https://helm.sh/docs/intro/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

After installation you should be able to run `terraform`, `helm`, `kubectl`, and `aws` as commands in the command line (these commands will show documentation when run without arguments).

## Configuration
There are a few configuration parameters that must be modified prior to running this installation. If you will be running applications in existing AWS infrastructure outside of the newly created EKS cluster, you will need to configure VPC peering (see below).

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
* `runner_pools`: Configuration for Exafunction runner node pools.
    * `suffix`: Unique suffix for the node pool name.
    * `node_instance_category`: One of (`cpu`, `gpu`).
    * `capacity_type`: One of (`ON_DEMAND`, `SPOT`).
    * `node_instance_type`: [AWS instance type](https://aws.amazon.com/ec2/instance-types/) for the node pool.
        * Should be a CPU instance type if `node_instance_category` is `cpu` (and likewise for GPU).
    * `disk_size`: Size of the disk in GB for the node pool.
    * `min_size`: Minimum number of nodes in the node pool.
    * `max_size`: Maximum number of nodes in the node pool.
    * `accelerator_label`: Label for the GPU accelerator.
        * Should be determined by the `node_instance_type`.
        * Only required if `node_instance_category` is `gpu`.
    * `additional_taints`: Additional taints to add to the node pool.
        * In most cases this should be left as an empty list.
    * `additional_labels`: Additional labels to add to the node pool.
        * In most cases this should be left as an empty map.
* `exadeploy_helm_chart_version`: The version of the [ExaDeploy Helm chart](https://github.com/Exafunction/helm-charts/tree/main/charts/exadeploy) to install.
    * This should be in the release provided by Exafunction.
* `api_key`: The API key used to identify your company to Exafunction.
    * This should be provided by Exafunction.
* `scheduler_image`: The image of the ExaDeploy scheduler.
    * This should be provided by Exafunction.
* `module_repository_image`: The image of the ExaDeploy module repository.
    * This should be provided by Exafunction.
* `runner_image`: The image of the ExaDeploy runner.
    * This should be provided by Exafunction.

### [`values.yaml`](/values.yaml)
Optional configuration for the [ExaDeploy Helm chart](https://github.com/Exafunction/helm-charts/tree/main/charts/exadeploy). This should only be necessary to add to in advanced use cases. To see Helm chart configuration options, see the Helm chart [values schema](https://github.com/Exafunction/helm-charts/tree/main/charts/exadeploy#values).

## Create
After finishing configuration, run
```bash
./create.sh
```
from the repository's root directory. It may take some time (up to 30 minutes) to finish applying as it needs to spin up and configure many new AWS resources. Note that `create.sh` is idempotent and can be rerun with updated configuration to update the deployed infrastructure.

## Running applications with ExaDeploy
For instructions on how to write and run applications that offload GPU computations to ExaDeploy, see our Quickstart Guide.

Applications running on external AWS infrastructure (i.e. not within the ExaDeploy cluster) will need to use the load balancer addresses for the ExaDeploy module repository and scheduler services.

To get these addresses, run these commands from the repository's root directory:

### Update Local Kubeconfig
```bash
aws eks update-kubeconfig \
    --region $(terraform -chdir=aws output -raw region) \
    --name $(terraform -chdir=aws output -raw cluster_name)
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

## Destroy
In order to destroy all the infrastructure set up by the repository, run
```bash
./destroy.sh
```
from the repository's root directory. This will delete all resources created by the installation including the ExaDeploy system, VPC peering connection, EKS cluster, and VPC.
