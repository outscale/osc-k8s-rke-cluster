locals {
  control_plane_names = [for i in range(var.control_plane_count) : format("ip-10-0-1-%d.eu-west-2.compute.internal", 10 + i)]
}

resource "outscale_subnet" "control-planes" {
  net_id         = outscale_net.net.net_id
  ip_range       = "10.0.1.0/24"
  subregion_name = "${var.region}a"

}

resource "outscale_route_table" "control-planes" {
  net_id = outscale_net.net.net_id

}

resource "outscale_route" "control-planes-default" {
  destination_ip_range = "0.0.0.0/0"
  nat_service_id       = outscale_nat_service.nat.nat_service_id
  route_table_id       = outscale_route_table.control-planes.route_table_id
}

resource "outscale_route_table_link" "control-planes" {
  subnet_id      = outscale_subnet.control-planes.subnet_id
  route_table_id = outscale_route_table.control-planes.route_table_id
}

resource "tls_private_key" "control-planes" {
  count     = var.control_plane_count
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "control-planes-pem" {
  count           = var.control_plane_count
  filename        = "${path.module}/control-planes/control-plane-${count.index}.pem"
  content         = tls_private_key.control-planes[count.index].private_key_pem
  file_permission = "0600"
}

resource "outscale_keypair" "control-planes" {
  count      = var.control_plane_count
  public_key = tls_private_key.control-planes[count.index].public_key_openssh
}

resource "outscale_security_group" "control-plane" {
  description = "Kubernetes control-planes (${var.cluster_name})"
  net_id      = outscale_net.net.net_id
}

resource "outscale_security_group_rule" "control-plane-ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.control-plane.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["10.0.0.0/24"]
  }

  # etcd
  rules {
    from_port_range = "2379"
    to_port_range   = "2380"
    ip_protocol     = "tcp"
    ip_ranges       = ["10.0.1.0/24"]
  }

  # service node port range
  rules {
    from_port_range = "30000"
    to_port_range   = "32767"
    ip_protocol     = "tcp"
    ip_ranges       = ["10.0.0.0/16"]
  }

  # kube-apiserver
  rules {
    from_port_range = "6443"
    to_port_range   = "6443"
    ip_protocol     = "tcp"
    ip_ranges       = ["10.0.0.0/16"]
  }
}

resource "outscale_vm" "control-planes" {
  count              = var.control_plane_count
  image_id           = outscale_image.node.image_id
  vm_type            = var.control_plane_vm_type
  keypair_name       = outscale_keypair.control-planes[count.index].keypair_name
  security_group_ids = [outscale_security_group.control-plane.security_group_id]
  subnet_id          = outscale_subnet.control-planes.subnet_id
  private_ips        = [format("10.0.1.%d", 10 + count.index)]

  provisioner "remote-exec" {
    inline = ["echo ok"]
    connection {
      type                = "ssh"
      user                = "outscale"
      host                = format("10.0.1.%d", 10 + count.index)
      private_key         = tls_private_key.control-planes[count.index].private_key_pem
      bastion_host        = outscale_public_ip.bastion.public_ip
      bastion_private_key = tls_private_key.bastion.private_key_pem
      bastion_user        = "outscale"
      bastion_port        = 22
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    bsu {
      volume_size = 15
      volume_type = "gp2"
    }
  }

  tags {
    key   = "name"
    value = "${var.cluster_name}-control-plane-${count.index}"
  }

  tags {
    key   = "OscK8sNodeName"
    value = local.control_plane_names[count.index]
  }
}

resource "outscale_tag" "control-planes-k8s-cluster-name" {
  count        = var.control_plane_count
  resource_ids = [outscale_vm.control-planes[count.index].vm_id]
  tag {
    key   = "OscK8sClusterID/${var.cluster_name}"
    value = "owned"
  }
}
