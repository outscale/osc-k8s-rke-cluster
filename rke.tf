resource "local_file" "rke_config_stdin" {
  filename        = "${path.root}/rke/rke-config.stdin"
  file_permission = "0660"
  content = format("%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
    // [+] Cluster Level SSH Private Key Path [~/.ssh/id_rsa]:
    "\n",
    // Number of Hosts [1]:
    "${var.worker_count + var.control_plane_count}\n",
    // for each control-plane
    join("\n", [for i in range(var.control_plane_count) : format("%s%s%s%s%s%s%s%s%s%s",
      // [+] SSH Address of host (1) [none]:
      format("10.0.1.%d\n", 10 + i),
      // [+] SSH Port of host (1) [22]:
      "\n",
      // [+] SSH Private Key Path of host (10.0.1.10) [none]:
      format("control-planes/control-plane-%s.pem\n", i),
      // [+] SSH User of host (10.0.1.10) [ubuntu]:
      "outscale\n",
      // [+] Is host (10.0.1.10) a Control Plane host (y/n)? [y]:
      "y\n",
      // [+] Is host (10.0.1.10) a Worker host (y/n)? [n]:
      "n\n",
      // [+] Is host (10.0.1.10) an etcd host (y/n)? [n]:
      "y\n",
      // [+] Override Hostname of host (10.0.1.10) [none]:
      "\n",
      // [+] Internal IP of host (10.0.1.10) [none]:
      format("10.0.1.%d\n", 10 + i),
      // [+] Docker socket path on host (10.0.1.10) [/var/run/docker.sock]:
      "\n"
    )]),
    // for each worker
    join("\n", [for i in range(var.worker_count) : format("%s%s%s%s%s%s%s%s%s%s",
      // [+] SSH Address of host (1) [none]:
      format("10.0.2.%d\n", 10 + i),
      // [+] SSH Port of host (1) [22]:
      "\n",
      // [+] SSH Private Key Path of host (10.0.2.10) [none]:
      format("workers/worker-%s.pem\n", i),
      // [+] SSH User of host (10.0.2.10) [ubuntu]:
      "outscale\n",
      // [+] Is host (10.0.2.10) a Control Plane host (y/n)? [y]:
      "n\n",
      // [+] Is host (10.0.2.10) a Worker host (y/n)? [n]:
      "y\n",
      // [+] Is host (10.0.2.10) an etcd host (y/n)? [n]:
      "n\n",
      // [+] Override Hostname of host (10.0.2.10) [none]:
      "\n",
      // [+] Internal IP of host (10.0.2.10) [none]:
      format("10.0.2.%d\n", 10 + i),
      // [+] Docker socket path on host (10.0.2.10) [/var/run/docker.sock]:
      "\n"
    )]),
    // [+] Network Plugin Type (flannel, calico, weave, canal, aci) [canal]:
    "calico\n",
    // [+] Authentication Strategy [x509]:
    "x509\n",
    // [+] Authorization Mode (rbac, none) [rbac]:
    "rbac\n",
    // [+] Kubernetes Docker image [rancher/hyperkube:v1.21.6-rancher1]:
    "rancher/hyperkube:v1.21.6-rancher1\n",
    // [+] Cluster domain [cluster.local]:
    "\n",
    // [+] Service Cluster IP Range [10.43.0.0/16]:
    "\n",
    // [+] Enable PodSecurityPolicy [n]:
    "\n",
    // [+] Cluster Network CIDR [10.42.0.0/16]:
    "\n",
    // [+] Cluster DNS Service IP [10.43.0.10]:
    "\n",
    // [+] Add addon manifest URLs or YAML files [no]:
  "\n")
}

resource "shell_script" "rke_cluster_yml" {
  lifecycle_commands {
    create = <<-EOF
        rke config -n ${path.root}/rke/cluster.yml < ${path.root}/rke/rke-config.stdin
        echo "cluster_name: \"${var.cluster_name}\"" >> ${path.root}/rke/cluster.yml
        echo "bastion_host:\n  address: \"${outscale_public_ip.bastion.public_ip}\"\n  port: \"22\"\n  user: \"outscale\"\n  ssh_key_path: \"${path.root}/bastion/bastion.pem\"" >> ${path.root}/rke/cluster.yml
    EOF
    read   = <<-EOF
        echo "{\"config\": \"$(cat ${path.root}/rke/cluster.yml|base64)\"}"
    EOF
    delete = <<-EOF
        rm -f ${path.root}/rke/cluster.yml
    EOF
  }
  depends_on = [local_file.rke_config_stdin]
}
