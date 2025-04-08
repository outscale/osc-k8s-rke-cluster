#access_key_id       = "MyAccessKey"
#secret_key_id       = "MySecretKey"
#region              = "eu-west-2"

# Ubuntu Image, check latest on https://docs.outscale.com/en/userguide/Official-OMIs-Reference.html
image_id                  = "ami-a3ca408c" #Ubuntu-22.04-2023.12.04-0 (created: 2024-01-04) on us-east-2
control_plane_vm_type     = "tinav7.c4r8p1"
control_plane_count       = 1
control_plane_volume_type = "gp2"
control_plane_volume_size = 15
control_plane_iops        = 1500
worker_vm_type            = "tinav7.c4r8p1"
worker_count              = 2
worker_volume_type        = "io1"
worker_volume_size        = 15
worker_iops               = 1500
bastion_vm_type           = "tinav7.c1r1p2"
bastion_volume_type       = "gp2"
bastion_volume_size       = 15
bastion_iops              = 1500 # ignored for gp2 volumes
cluster_name              = "phandalin"
rke_version               = "v1.7.3"
kubernetes_version        = "v1.31.5-rancher1-1"
will_install_ccm          = false # Set to true if the CCM of osc will be installed
public_cloud              = false
