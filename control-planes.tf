locals {
  control_plane_names = [for i in range(var.control_plane_count) : format("ip-10-0-1-%d.%s.compute.internal", 10 + i, var.region)]
}

resource "tls_private_key" "control-planes" {
  count     = var.control_plane_count
  algorithm = "ED25519"
}

resource "tls_private_key" "control-planes-sshd" {
  count     = var.control_plane_count
  algorithm = "ED25519"
}

resource "local_file" "control-planes-pem" {
  count           = var.control_plane_count
  filename        = "${path.module}/control-planes/control-plane-${count.index}.pem"
  content         = tls_private_key.control-planes[count.index].private_key_openssh
  file_permission = "0600"
}

resource "outscale_keypair" "control-planes" {
  count      = var.control_plane_count
  public_key = tls_private_key.control-planes[count.index].public_key_openssh
}

resource "outscale_public_ip" "control-planes" {
  count = var.public_cloud ? var.control_plane_count : 0
}

resource "outscale_public_ip_link" "control-planes" {
  count     = var.public_cloud ? var.control_plane_count : 0
  vm_id     = outscale_vm.control-planes[count.index].vm_id
  public_ip = outscale_public_ip.control-planes[count.index].public_ip
}

resource "outscale_security_group" "control-plane" {
  description = "Kubernetes control-planes (${var.cluster_name})"
  net_id      = var.public_cloud ? null : outscale_net.net[0].net_id
}

resource "outscale_security_group_rule" "control-plane-ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.control-plane.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = var.public_cloud ? ["0.0.0.0/0"] : ["10.0.0.0/24"]
  }

  # etcd
  rules {
    from_port_range = "2379"
    to_port_range   = "2380"
    ip_protocol     = "tcp"
    ip_ranges       = var.public_cloud ? [for i in range(var.control_plane_count) : format("%s/32", outscale_public_ip.control-planes[i].public_ip)] : ["10.0.1.0/24"]
  }

  # kube-apiserver
  rules {
    from_port_range = "6443"
    to_port_range   = "6443"
    ip_protocol     = "tcp"
    ip_ranges       = var.public_cloud ? ["0.0.0.0/0"] : ["10.0.0.0/16"]
  }
}

resource "outscale_vm" "control-planes" {
  count              = var.control_plane_count
  image_id           = outscale_image.node.image_id
  vm_type            = var.control_plane_vm_type
  keypair_name       = outscale_keypair.control-planes[count.index].keypair_name
  security_group_ids = [outscale_security_group.control-plane.security_group_id, outscale_security_group.node.security_group_id, outscale_security_group.worker.security_group_id]
  subnet_id          = var.public_cloud ? null : outscale_subnet.nodes[0].subnet_id
  private_ips        = var.public_cloud ? null : [format("10.0.1.%d", 10 + count.index)]
  user_data = base64encode(format("#cloud-config\nssh:\n  emit_keys_to_console: false\nssh_keys:\n  ed25519_private: |\n    %s\n  ed25519_public: %s",
    indent(4, tls_private_key.control-planes-sshd[count.index].private_key_openssh),
  replace(tls_private_key.control-planes-sshd[count.index].public_key_openssh, "\n", "")))
  provisioner "remote-exec" {
    inline = ["echo ok"]
    connection {
      type                = "ssh"
      user                = "outscale"
      host                = var.public_cloud ? self.public_ip : format("10.0.1.%d", 10 + count.index)
      private_key         = tls_private_key.control-planes[count.index].private_key_openssh
      bastion_host        = var.public_cloud ? null : outscale_public_ip.bastion.public_ip
      bastion_private_key = var.public_cloud ? null : tls_private_key.bastion.private_key_openssh
      bastion_user        = var.public_cloud ? null : "outscale"
      bastion_port        = var.public_cloud ? null : 22
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    bsu {
      delete_on_vm_deletion = true
      volume_size           = var.control_plane_volume_size
      volume_type           = var.control_plane_volume_type
      iops                  = var.control_plane_volume_type == "io1" ? var.control_plane_iops : null
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

  dynamic "tags" {
    for_each = var.public_cloud ? [1] : []
    content {
      key   = "osc.fcu.eip.auto-attach"
      value = outscale_public_ip.control-planes[count.index].public_ip
    }
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
