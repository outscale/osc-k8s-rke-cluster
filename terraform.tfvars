#access_key_id       = "MyAccessKey"
#secret_key_id       = "MySecretKey"
#region              = "eu-west-2"

# Ubuntu Image, check latest on https://docs.outscale.com/en/userguide/Official-OMIs-Reference.html
image_id                  = "ami-ec7ef91f" # Ubuntu-22.04-2022.12.06-0 on eu-west-2
control_plane_vm_type     = "tinav5.c4r8p1"
control_plane_count       = 1
control_plane_volume_type = "io1"
control_plane_volume_size = 15
control_plane_iops        = 1500
worker_vm_type            = "tinav5.c4r8p1"
worker_count              = 2
worker_volume_type        = "io1"
worker_volume_size        = 15
worker_iops               = 1500
bastion_vm_type           = "tinav5.c4r8p1"
bastion_volume_type       = "io1"
bastion_volume_size       = 15
bastion_iops              = 1500
cluster_name              = "phandalin"
kubernetes_version        = "v1.24.8-rancher1-1" # See available version https://github.com/rancher/rke/releases
will_install_ccm          = false                # Set to true if the CCM of osc will be installed 
public_cloud              = false
