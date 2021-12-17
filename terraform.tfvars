#access_key_id       = "MyAccessKey"
#secret_key_id       = "MySecretKey"
#region              = "eu-west-2"

image_id              = "ami-4779e795" # Ubuntu-20.04-2021.09.09-0 on eu-west-2
control_plane_vm_type = "tinav5.c4r8p1"
control_plane_count   = 1
worker_vm_type        = "tinav5.c4r8p1"
worker_count          = 1
bastion_vm_type       = "tinav5.c4r8p1"
cluster_name          = "phandalin"
