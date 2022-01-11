resource "random_id" "node_image_name" {
  byte_length = 8
}

resource "outscale_image" "node" {
  image_name = "${var.cluster_name}-${random_id.node_image_name.hex}"
  vm_id      = outscale_vm.bastion.vm_id
  no_reboot  = "true"
  depends_on = [shell_script.bastion-playbook]
}


resource "outscale_security_group" "node" {
  description = "Kubernetes node (${var.cluster_name})"
  net_id      = outscale_net.net.net_id
  tags {
    key   = "OscK8sClusterID/${var.cluster_name}"
    value = "owned"
  }

  tags {
    key   = "OscK8sMainSG/${var.cluster_name}"
    value = "True"
  }
}