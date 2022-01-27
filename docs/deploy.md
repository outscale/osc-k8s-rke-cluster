# Prerequisite

- [Terraform](https://www.terraform.io/downloads) (>= 0.14)
- [RKE](https://rancher.com/docs/rke/latest/en/installation/) (>= v1.3.4)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) (>= 2.4)
- [Outscale Access Key and Secret Key](https://wiki.outscale.net/display/EN/Creating+an+Access+Key)

# Configuration

```
export TF_VAR_access_key_id="myaccesskey"
export TF_VAR_secret_key_id="mysecretkey"
export TF_VAR_region="eu-west-2"
```


By editing ['terraform.tfvars'](terraform.tfvars), you can adjust the number of worker/control-plane nodes, size of node and more.

# Deploying infrastructure

This step will create infrastructure components as well as configuration files needed to bootstrap cluster creation.

```
terraform init
terraform apply
```

# Deploying Kubernetes cluster

Once your infrastructure ready, you are ready to deploy RKE and some cloud specific controllers like cloud controller manager (CCM) and cloud storage interface (CSI).

First, deploy RKE (this will also install CCM):
```
rke up --config rke/cluster.yml
```

Then to complete the cluster initialization, install the CSI driver:
```
scp -F ssh_config rke/kube_config_cluster.yml bastion:.kube/config
ANSIBLE_CONFIG=ansible.cfg ansible-playbook csi/playbook.yaml
```

# Querying the cluster

Once RKE deployment is successful, you should be able to list nodes and use your cluster.

```
export KUBECONFIG=rke/kube_config_cluster.yml
kubectl get nodes
```

For further testing, check [testing section](testing.md).

If needed, you can connect to any worker or control-plane node using SSH:
```
ssh -F ssh_config worker-0
ssh -F ssh_config control-plane-0
```

# Cleaning Up
First destroy your cluster using RKE, this will also remove dynamically created cloud resources perfomed by CCM or CSI.
```
rke remove --config rke/cluster.yml
```

And then destroy the infrastructure: 
```
terraform destroy
```

Alternatively, you can manually cleanup your resources if something goes wrong:
- Connect to [cockpit interface](https://cockpit.outscale.com/)
- Go to VPC->VPCs, Select the created VPC, click the "Teardown" button and validate.
- Go to Network/Security->Keypairs and delete Keypairs created for each node
- Go to Network/Security->External Ips and delete EIP created for each control-planes
- Go to Compute->Outscale Machine Image and delete created image
