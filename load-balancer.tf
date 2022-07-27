resource "outscale_security_group" "lb-kube-apiserver" {
  count       = var.public_cloud ? 0 : 1
  description = "Kubernetes LB kube-apiserver (${var.cluster_name})"
  net_id      = var.public_cloud ? null : outscale_net.net[0].net_id
}

resource "outscale_security_group_rule" "kube-apiserver" {
  count             = var.public_cloud ? 0 : 1
  flow              = "Inbound"
  security_group_id = outscale_security_group.lb-kube-apiserver[0].id
  rules {
    from_port_range = "6443"
    to_port_range   = "6443"
    ip_protocol     = "tcp"
    ip_ranges       = ["0.0.0.0/0"]
  }
}

resource "outscale_load_balancer" "lb-kube-apiserver" {
  load_balancer_name = "${var.cluster_name}-kube-apiserver"
  subnets            = var.public_cloud ? null : [outscale_subnet.nodes[0].subnet_id]
  security_groups    = var.public_cloud ? null : [outscale_security_group.lb-kube-apiserver[0].security_group_id]
  subregion_names    = var.public_cloud ? [format("%sa", var.region)] : null
  listeners {
    backend_port           = 6443
    backend_protocol       = "TCP"
    load_balancer_protocol = "TCP"
    load_balancer_port     = 6443
  }
}

resource "local_file" "kube-apiserver-url" {
  filename        = "${path.root}/kube-apiserver-url.txt"
  file_permission = "0660"
  content         = "https://${outscale_load_balancer.lb-kube-apiserver.dns_name}"
}

resource "outscale_load_balancer_vms" "backend_vms" {
  count              = var.control_plane_count
  load_balancer_name = outscale_load_balancer.lb-kube-apiserver.load_balancer_name
  backend_vm_ids     = [outscale_vm.control-planes[count.index].vm_id]
}

resource "outscale_load_balancer_attributes" "lb-kube-apiserver" {
  load_balancer_name = outscale_load_balancer.lb-kube-apiserver.load_balancer_name
  health_check {
    healthy_threshold   = 10
    check_interval      = 30
    port                = 6443
    protocol            = "TCP"
    timeout             = 5
    unhealthy_threshold = 5
  }
}
