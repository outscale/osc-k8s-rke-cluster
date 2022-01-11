locals {
  node_names = [for i in range(var.worker_count) : format("ip-10-0-2-%d.eu-west-2.compute.internal", 10 + i)]
}

resource "outscale_subnet" "workers" {
  net_id         = outscale_net.net.net_id
  ip_range       = "10.0.2.0/24"
  subregion_name = "${var.region}a"
}

resource "outscale_route_table" "workers" {
  net_id = outscale_net.net.net_id
}

resource "outscale_route" "workers-default" {
  destination_ip_range = "0.0.0.0/0"
  nat_service_id       = outscale_nat_service.nat.nat_service_id
  route_table_id       = outscale_route_table.workers.route_table_id
}

resource "outscale_route" "worker-pods" {
  count                = var.worker_count
  destination_ip_range = "10.42.${count.index}.0/24"
  vm_id                = outscale_vm.workers[count.index].vm_id
  route_table_id       = outscale_route_table.workers.route_table_id
}

resource "outscale_route" "worker-services" {
  count                = var.worker_count
  destination_ip_range = "10.43.${count.index}.0/24"
  vm_id                = outscale_vm.workers[count.index].vm_id
  route_table_id       = outscale_route_table.workers.route_table_id
}

resource "outscale_route_table_link" "workers" {
  subnet_id      = outscale_subnet.workers.subnet_id
  route_table_id = outscale_route_table.workers.route_table_id
}

resource "tls_private_key" "workers" {
  count     = var.worker_count
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "workers-pem" {
  count           = var.worker_count
  filename        = "${path.module}/workers/worker-${count.index}.pem"
  content         = tls_private_key.workers[count.index].private_key_pem
  file_permission = "0600"
}

resource "outscale_keypair" "workers" {
  count      = var.worker_count
  public_key = tls_private_key.workers[count.index].public_key_openssh
}

resource "outscale_security_group" "worker" {
  description = "Kubernetes workers (${var.cluster_name})"
  net_id      = outscale_net.net.net_id
  tags {
    key   = "OscK8sClusterID/${var.cluster_name}"
    value = "owned"
  }
}

resource "outscale_security_group_rule" "worker-rules" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.worker.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["10.0.0.0/16"]
  }
  rules {
    ip_protocol = "-1"
    ip_ranges   = ["10.0.0.10/32", "10.0.1.0/24", "10.0.2.0/24"]
  }
}

resource "outscale_vm" "workers" {
  count              = var.worker_count
  image_id           = outscale_image.node.image_id
  vm_type            = var.worker_vm_type
  keypair_name       = outscale_keypair.workers[count.index].keypair_name
  security_group_ids = [outscale_security_group.worker.security_group_id]
  subnet_id          = outscale_subnet.workers.subnet_id
  private_ips        = [format("10.0.2.%d", 10 + count.index)]

  block_device_mappings {
    device_name = "/dev/sda1"
    bsu {
      volume_size = 15
      volume_type = "gp2"
    }
  }

  provisioner "remote-exec" {
    inline = ["echo ok"]
    connection {
      type                = "ssh"
      user                = "outscale"
      host                = format("10.0.2.%d", 10 + count.index)
      private_key         = tls_private_key.workers[count.index].private_key_pem
      bastion_host        = outscale_public_ip.bastion.public_ip
      bastion_private_key = tls_private_key.bastion.private_key_pem
      bastion_user        = "outscale"
      bastion_port        = 22
    }
  }

  tags {
    key   = "name"
    value = "${var.cluster_name}-worker-${count.index}"
  }

  tags {
    key   = "OscK8sNodeName"
    value = local.node_names[count.index]
  }
}

# A bug in metadata make cloud-init crash with a tag containing a / so we apply it after VM finished starting.
# This tag is needed for CCM
resource "outscale_tag" "workers-k8s-cluster-name" {
  count        = var.worker_count
  resource_ids = [outscale_vm.workers[count.index].vm_id]
  tag {
    key   = "OscK8sClusterID/${var.cluster_name}"
    value = "owned"
  }
}
