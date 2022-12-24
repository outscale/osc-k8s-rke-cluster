# deploy_cluster

## Description
This Github action allows you to deploy a k8s cluster in the Outscale Cloud.
See [action.yml](action.yml)

## Inputs

| Parameter                   | Description                                                                                  | Required | Default                                 |
| :-------------------------- | :------------------------------------------------------------------------------------------- | :------- | :-------------------------------------- |
| `osc_access_key`            | OSC Access Key                                                                               | `true`   | `""`                                    |
| `osc_secret_key`            | OSC Secret Key                                                                               | `true`   | `""`                                    |
| `osc_region`                | OSC region                                                                                   | `true`   | `""`                                    |
| `will_install_ccm`          | Configure the cluster for future CCM installation ("true" or "false")                        | `false`  | `"false"`                               |
| `public_cloud`              | Deploy the cluster in the public or private cloud ("true" for public or "false" for private) | `false`  | `"false"`                               |
| `repository_folder`         | Folder where this repo is stored                                                             | `false`  | `"./"`                                  |
| `rke_version`               | Version of rke to use                                                                        | `false`  | `"v1.4.1"`                              |
| `kubernetes_version`        | Version of the kubernetes to deploy (See https://github.com/rancher/rke/releases)            | `false`  | `"v1.24.8-rancher1-1"`                  |
| `bastion_vm_type`           | Vm type of bastion instance                                                                  | `false`  | `"tinav5.c4r8p1"`                       |
| `bastion_volume_type`       | Volume type of bastion instance                                                              | `false`  | `"gp2"`                                 |
| `bastion_volume_size`       | Volume size of bastion instance                                                              | `false`  | `15`                                    |
| `bastion_volume_iops`       | Volume iops of bastion instance                                                              | `false`  | `1500`                                  |
| `control_plane_vm_type`     | Vm type of control plane instance                                                            | `false`  | `"tinav5.c4r8p1"`                       |
| `control_plane_count`       | Number of control plane instance                                                             | `false`  | `1`                                     |
| `control_plane_volume_type` | Volume type of control plane instance                                                        | `false`  | `"gp2"`                                 |
| `control_plane_volume_size` | Volume size of control plane instance                                                        | `false`  | `15`                                    |
| `control_plane_volume_size` | Volume iops of control plane instance                                                        | `false`  | `1500`                                  |
| `worker_vm_type`            | Vm type of worker instance                                                                   | `false`  | `"tinav5.c4r8p1"`                       |
| `worker_count`              | Number of worker instance                                                                    | `false`  | `2`                                     |
| `worker_volume_type`        | Volume type of worker instance                                                               | `false`  | `"standard"`                            |
| `worker_volume_size`        | Volume size of worker instance                                                               | `false`  | `15`                                    |
| `worker_volume_iops`        | Volume iops of worker instance                                                               | `false`  | `1500`                                  |
| `image_id`                  | Image ID used for all VMs                                                                    | `false`  | `ami-d76e520a` (available in eu-west-2) |

## Output
N/A

## Example
### Basic Example
```yaml
name: basic example
on:
  push:
    branches:    
      - 'master'

jobs:
  deploy:
    runs-on:  ubuntu-latest
    needs: code-quality
    steps:
    - uses: actions/checkout@v2
    - name: Deploy Cluster
      uses: outscale-dev/osc-k8s-rke-cluster/github_actions/deploy_cluster@master
      with:
        repository_folder: "./"
        osc_access_key: ${{ secrets.OSC_ACCESS_KEY }}
        osc_secret_key: ${{ secrets.OSC_SECRET_KEY }}
        osc_region: ${{ secrets.OSC_REGION }}
        kubernetes_version: "v1.24.8-rancher1-1"
        bastion_vm_type: "tinav5.c4r8p1"
        bastion_volume_type: "io1"
        bastion_volume_size: 30
        bastion_iops: 1500
        control_plane_vm_type: "tinav5.c4r8p1"
        control_plane_count: 1
        control_plane_volume_type: "io1"
        control_plane_volume_size: 30
        control_plane_iops: 1500
        worker_vm_type: "tinav5.c4r8p1"
        worker_count: 2
        worker_volume_type: "io1"
        worker_volume_size: 30
        worker_iops: 1500
```
