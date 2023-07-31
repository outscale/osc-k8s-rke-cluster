
# http data source don't manage binary data
resource "null_resource" "rke_binary" {
  triggers = {
    on_version_change = "${var.rke_version}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/rke/ && curl -L -o ${path.root}/rke/rke https://github.com/rancher/rke/releases/download/${var.rke_version}/rke_linux-amd64 && chmod +x ${path.root}/rke/rke"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ${path.root}/rke/rke"
  }
}

resource "local_file" "rke_cluster_yml" {
  filename        = "${path.root}/rke/cluster.yml"
  file_permission = "0660"
  content = format("%s%s%s%s",
    "nodes:\n",
    join("\n", [for i in range(var.control_plane_count) : format(
      <<EOT
- address: %s
  port: 22
  role:
  - controlplane
  - etcd
  - worker
  hostname_override: %s
  user: outscale
  docker_socket: /var/run/docker.sock
  ssh_key:
  ssh_key_path: control-planes/control-plane-%d.pem
  ssh_cert:
  ssh_cert_path:
  labels: {}
  taints: []
EOT
    , var.public_cloud ? outscale_public_ip.control-planes[i].public_ip : outscale_vm.control-planes[i].private_ip, outscale_vm.control-planes[i].private_dns_name, i)]),
    join("\n", [for i in range(var.worker_count) : format(
      <<EOT
- address: %s
  port: 22
  role:
  - worker
  hostname_override: %s
  user: outscale
  docker_socket: /var/run/docker.sock
  ssh_key:
  ssh_key_path: workers/worker-%d.pem
  ssh_cert:
  ssh_cert_path:
  labels: {}
  taints: []
EOT
    , var.public_cloud ? outscale_public_ip.workers[i].public_ip : outscale_vm.workers[i].private_ip, outscale_vm.workers[i].private_dns_name, i)]),

    <<EOT
services:
  etcd:
    image:
    extra_args: {}
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
    external_urls: []
    ca_cert:
    cert:
    key:
    path:
    uid: 0
    gid: 0
    snapshot: null
    retention:
    creation:
    backup_config: null
  kube-api:
    image:
    extra_args:
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
    service_cluster_ip_range: 10.43.0.0/16
    service_node_port_range:
    pod_security_policy: false
    always_pull_images: false
    secrets_encryption_config: null
    audit_log: null
    admission_configuration: null
    event_rate_limit: null
  kube-controller:
    image:
    extra_args: {}
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
  scheduler:
    image:
    extra_args: {}
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
  kubelet:
    image:
    extra_args:
      read-only-port: 10255
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
    cluster_domain: cluster.local
    infra_container_image:
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
    generate_serving_certificate: false
  kubeproxy:
    image:
    extra_args: {}
    extra_binds: []
    extra_env: []
    win_extra_args: {}
    win_extra_binds: []
    win_extra_env: []
network:
  plugin: calico
  options: {}
  mtu: 0
  node_selector: {}
  update_strategy: null
  tolerations: []
authentication:
  strategy: x509
  sans:
${var.public_cloud ? "" : join("\n", [for i in range(var.control_plane_count) : format("   - 10.0.1.%d", 10 + i)])}
   - ${outscale_load_balancer.lb-kube-apiserver.dns_name}
  webhook: null
addons:
addons_include:
ssh_key_path: ~/.ssh/id_ed25519
ssh_cert_path:
ssh_agent_auth: false
authorization:
  mode: rbac
  options: {}
ignore_docker_version: null
enable_cri_dockerd: null
kubernetes_version: ${var.kubernetes_version}
private_registries: []
ingress:
  provider:
  options: {}
  node_selector: {}
  extra_args: {}
  dns_policy:
  extra_envs: []
  extra_volumes: []
  extra_volume_mounts: []
  update_strategy: null
  http_port: 0
  https_port: 0
  network_mode:
  tolerations: []
  default_backend: null
  default_http_backend_priority_class_name:
  nginx_ingress_controller_priority_class_name:
cluster_name: ${var.cluster_name}
cloud_provider:
${var.will_install_ccm ? "  name: \"external\"" : ""}
prefix_path:
win_prefix_path:
addon_job_timeout: 0
monitoring:
  provider:
  options: {}
  node_selector: {}
  update_strategy: null
  replicas: null
  tolerations: []
  metrics_server_priority_class_name:
restore:
  restore: false
  snapshot_name:
rotate_encryption_key: false
dns: null
${var.public_cloud ? "" : format("bastion_host:\n  address: ${outscale_public_ip.bastion.public_ip}\n  port: 22\n  user: outscale\n  ssh_key_path: ${path.root}/bastion/bastion.pem")}
EOT
  )
  depends_on = [local_file.csi_secrets]
}
