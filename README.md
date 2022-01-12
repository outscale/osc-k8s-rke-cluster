# Kubernetes Cluster With RKE On Outscale Cloud

This reprository contain a way to deploy a [kubernetes](https://kubernetes.io/) cluster using [rke](https://rancher.com/docs/rke/) on [Outscale cloud provider](https://outscale.com/).

# Architecture

The Kubernetes cluster is deployed inside a [Net](https://wiki.outscale.net/display/EN/About+VPCs) with three [Subnets](https://wiki.outscale.net/display/EN/Getting+Information+About+Your+Subnets):
- One subnet (10.0.0.0/24) containing a bastion host, and a [NAT Service](https://wiki.outscale.net/display/EN/About+NAT+Gateways)
- One subnet (10.0.0.1/24) containing control plane nodes
- One subnet (10.0.0.2/24) containing woker nodes

# Prerequisite

- [Terraform](https://www.terraform.io/downloads) (>= 0.14)
- [RKE](https://rancher.com/docs/rke/latest/en/installation/) (>= v1.3.2)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) (>= 2.4)
- [Outscale Access Key and Secret Key](https://wiki.outscale.net/display/EN/Creating+an+Access+Key)

# Configuration

```
export TF_VAR_access_key_id="myaccesskey"
export TF_VAR_secret_key_id="mysecretkey"
export TF_VAR_region="eu-west-2"
```


By editing ['terraform.tfvars'](terraform.tfvars), you can adjust the number of worker/control-plane nodes, size of node and more.

# Deploy

First deploy infrastructure resources:
```
terraform init
terraform apply
```

Then you should be able to deploy RKE using:
```
rke up --config rke/cluster.yml
```

You can now copy your kubeconfig file to bastion host:
```
scp -F ssh_config rke/kube_config_cluster.yml bastion:.kube/config
```

Connect to bastion and test kubeapi-server:
```
ssh -F ssh_config bastion
kubectl get nodes
```

If needed, you can connect to any worker or control-plane node:
```
ssh -F ssh_config worker-0
ssh -F ssh_config control-plane-0
```

# Smoke Test

Smoke testing our newly created Kubernetes cluster can be done very similarely to [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md).

Note that workers has no public IP so you can test Nodeport service from bastion.

# Cleaning Up

Just run `terraform destroy`.

Alternatively, you can manually cleanup your resources if something goes wrong:
- Connect to [cockpit interface](https://cockpit.outscale.com/)
- Go to VPC->VPCs, Select the created VPC, click the "Teardown" button and validate.
- Go to Network/Security->Keypairs and delete Keypairs created for each node
- Go to Network/Security->External Ips and delete EIP created for each control-planes
- Go to Compute->Outscale Machine Image and delete created image

# Contributing

Feel free to report an issue.
