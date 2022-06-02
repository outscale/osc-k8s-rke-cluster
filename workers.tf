
locals {
  node_names = [for i in range(var.worker_count) : format("ip-10-0-1-%d.%s.compute.internal", 19 + i, var.region)]
}

resource "tls_private_key" "workers" {
  count     = var.worker_count
  algorithm = "RSA"
  rsa_bits  = "4096"
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
    ip_ranges   = ["10.0.0.10/32", "10.0.1.0/24"]
  }
}

resource "outscale_vm" "workers" {
  count              = var.worker_count
  image_id           = outscale_image.node.image_id
  vm_type            = var.worker_vm_type
  keypair_name       = outscale_keypair.workers[count.index].keypair_name
  security_group_ids = [outscale_security_group.worker.security_group_id, outscale_security_group.node.security_group_id]
  subnet_id          = outscale_subnet.nodes.subnet_id
  private_ips        = [format("10.0.1.%d", 19 + count.index)]

  block_device_mappings {
    device_name = "/dev/sda1"
    bsu {
      delete_on_vm_deletion = true
      volume_size           = var.worker_volume_size
      volume_type           = var.worker_volume_type
      iops                  = var.worker_volume_type == "io1" ? var.worker_iops : 0
    }
  }

  provisioner "remote-exec" {
    inline = ["echo ok"]
    connection {
      type                = "ssh"
      user                = "outscale"
      host                = format("10.0.1.%d", 19 + count.index)
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
