resource "outscale_subnet" "bastion" {
  count          = var.public_cloud ? 0 : 1
  net_id         = outscale_net.net[0].net_id
  ip_range       = "10.0.0.0/24"
  subregion_name = "${var.region}a"

  tags {
    key   = "OscK8sClusterID/${var.cluster_name}"
    value = "owned"
  }
}

resource "outscale_route_table" "bastion" {
  count  = var.public_cloud ? 0 : 1
  net_id = outscale_net.net[0].net_id

  tags {
    key   = "OscK8sClusterID/${var.cluster_name}"
    value = "owned"
  }
}

resource "outscale_route" "bastion-default" {
  count                = var.public_cloud ? 0 : 1
  destination_ip_range = "0.0.0.0/0"
  gateway_id           = outscale_internet_service.internet_service[0].internet_service_id
  route_table_id       = outscale_route_table.bastion[0].route_table_id
}

resource "outscale_route_table_link" "bastion" {
  count          = var.public_cloud ? 0 : 1
  subnet_id      = outscale_subnet.bastion[0].subnet_id
  route_table_id = outscale_route_table.bastion[0].route_table_id
}

resource "outscale_public_ip" "nat" {
  count = var.public_cloud ? 0 : 1
}

resource "outscale_nat_service" "nat" {
  count        = var.public_cloud ? 0 : 1
  subnet_id    = outscale_subnet.bastion[0].subnet_id
  public_ip_id = outscale_public_ip.nat[0].id
}

resource "outscale_public_ip" "bastion" {}

resource "outscale_public_ip_link" "bastion" {
  vm_id     = outscale_vm.bastion.vm_id
  public_ip = outscale_public_ip.bastion.public_ip
}

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "bastion-pem" {
  filename        = "${path.module}/bastion/bastion.pem"
  content         = tls_private_key.bastion.private_key_pem
  file_permission = "0600"
}

resource "outscale_keypair" "bastion" {
  public_key = tls_private_key.bastion.public_key_openssh
}

resource "outscale_security_group" "bastion" {
  description = "Bastion (${var.cluster_name})"
  net_id      = var.public_cloud ? null : outscale_net.net[0].net_id
}

resource "outscale_security_group_rule" "bastion-ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.bastion.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["0.0.0.0/0"]
  }
}

resource "outscale_vm" "bastion" {
  image_id           = var.image_id
  vm_type            = var.bastion_vm_type
  keypair_name       = outscale_keypair.bastion.keypair_name
  security_group_ids = [outscale_security_group.bastion.security_group_id]
  subnet_id          = var.public_cloud ? null : outscale_subnet.bastion[0].subnet_id
  private_ips        = var.public_cloud ? null : ["10.0.0.10"]

  block_device_mappings {
    device_name = "/dev/sda1"
    bsu {
      delete_on_vm_deletion = true
      volume_size           = var.bastion_volume_size
      volume_type           = var.bastion_volume_type
      iops                  = var.bastion_volume_type == "io1" ? var.bastion_iops : 0
    }
  }

  tags {
    key   = "osc.fcu.eip.auto-attach"
    value = outscale_public_ip.bastion.public_ip
  }

  tags {
    key   = "name"
    value = "${var.cluster_name}-bastion"
  }
}

resource "shell_script" "bastion-playbook" {
  lifecycle_commands {
    create = <<-EOF
        ANSIBLE_CONFIG=ansible.cfg ansible-playbook bastion/playbook.yaml
    EOF
    update = <<-EOF
        ANSIBLE_CONFIG=ansible.cfg ansible-playbook --extra-vars "{\"kubectl_version\": \"${element(split("-rancher", var.kubernetes_version), 0)}\"}" bastion/playbook.yaml
    EOF
    read   = <<-EOF
        echo "{\"file\": \"$(cat bastion/playbook.yaml|base64)\",
               \"check\": \"$(ANSIBLE_CONFIG=ansible.cfg ansible-playbook --check bastion/playbook.yaml|base64)\"
              }"
    EOF
    delete = ""
  }
  depends_on = [outscale_public_ip_link.bastion]
}
