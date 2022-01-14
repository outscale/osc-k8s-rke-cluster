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
  net_id         = outscale_net.net.net_id
  ip_range       = "10.0.1.0/24"
  subregion_name = "${var.region}a"
}

resource "outscale_route_table" "nodes" {
  net_id = outscale_net.net.net_id
}

resource "outscale_route" "node-default" {
  destination_ip_range = "0.0.0.0/0"
  nat_service_id       = outscale_nat_service.nat.nat_service_id
  route_table_id       = outscale_route_table.nodes.route_table_id
}

resource "outscale_route" "node-pods" {
  count                = var.worker_count
  destination_ip_range = "10.42.${count.index}.0/24"
  vm_id                = outscale_vm.workers[count.index].vm_id
  route_table_id       = outscale_route_table.nodes.route_table_id
}

resource "outscale_route" "node-services" {
  count                = var.worker_count
  destination_ip_range = "10.43.${count.index}.0/24"
  vm_id                = outscale_vm.workers[count.index].vm_id
  route_table_id       = outscale_route_table.nodes.route_table_id
}

resource "outscale_route_table_link" "nodes" {
  subnet_id      = outscale_subnet.nodes.subnet_id
  route_table_id = outscale_route_table.nodes.route_table_id
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