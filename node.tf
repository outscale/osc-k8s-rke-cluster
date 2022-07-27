resource "random_id" "node_image_name" {
  byte_length = 8
}

resource "outscale_image" "node" {
  image_name = "${var.cluster_name}-${random_id.node_image_name.hex}"
  vm_id      = outscale_vm.bastion.vm_id
  no_reboot  = "true"
  depends_on = [shell_script.bastion-playbook]
}


resource "outscale_subnet" "nodes" {
  count          = var.public_cloud ? 0 : 1
  net_id         = outscale_net.net[0].net_id
  ip_range       = "10.0.1.0/24"
  subregion_name = "${var.region}a"
}

resource "outscale_route_table" "nodes" {
  count  = var.public_cloud ? 0 : 1
  net_id = outscale_net.net[0].net_id
}

resource "outscale_route" "node-default" {
  count                = var.public_cloud ? 0 : 1
  destination_ip_range = "0.0.0.0/0"
  nat_service_id       = outscale_nat_service.nat[0].nat_service_id
  route_table_id       = outscale_route_table.nodes[0].route_table_id
}

resource "outscale_route" "node-pods" {
  count                = var.public_cloud ? 0 : var.worker_count
  destination_ip_range = "10.42.${count.index}.0/24"
  vm_id                = outscale_vm.workers[count.index].vm_id
  route_table_id       = outscale_route_table.nodes[0].route_table_id
}

resource "outscale_route" "node-services" {
  count                = var.public_cloud ? 0 : var.worker_count
  destination_ip_range = "10.43.${count.index}.0/24"
  vm_id                = outscale_vm.workers[count.index].vm_id
  route_table_id       = outscale_route_table.nodes[0].route_table_id
}

resource "outscale_route_table_link" "nodes" {
  count          = var.public_cloud ? 0 : 1
  subnet_id      = outscale_subnet.nodes[0].subnet_id
  route_table_id = outscale_route_table.nodes[0].route_table_id
}


resource "outscale_security_group" "node" {
  description = "Kubernetes node (${var.cluster_name})"
  net_id      = var.public_cloud ? null : outscale_net.net[0].net_id
  tags {
    key   = "OscK8sClusterID/${var.cluster_name}"
    value = "owned"
  }

  tags {
    key   = "OscK8sMainSG/${var.cluster_name}"
    value = "True"
  }
}