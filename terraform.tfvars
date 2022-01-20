#access_key_id       = "MyAccessKey"
#secret_key_id       = "MySecretKey"
#region              = "eu-west-2"

image_id              = "ami-37b14bc1" # Ubuntu-20.04-2021.09.09-0 on eu-west-2 (copy)
control_plane_vm_type = "tinav5.c4r8p1"
control_plane_count   = 1
worker_vm_type        = "tinav5.c4r8p1"
worker_count          = 2
bastion_vm_type       = "tinav5.c4r8p1"
cluster_name          = "phandalin"
kubernetes_version    = "v1.22.5-rancher1-1" # See available version https://github.com/rancher/rke/releases
