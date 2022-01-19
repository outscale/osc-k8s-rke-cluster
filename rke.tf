resource "local_file" "rke_cluster_yml" {
  filename        = "${path.root}/rke/cluster.yml"
  file_permission = "0660"
  content = format("%s%s%s%s",
    "nodes:\n",
    join("\n", [for i in range(var.control_plane_count) : format(
      <<EOT
- address: 10.0.1.%d
  port: 22
  role:
  - controlplane
  - etcd
  - worker
  hostname_override: ip-10-0-1-%d.%s.compute.internal
  user: outscale
  docker_socket: /var/run/docker.sock
  ssh_key:
  ssh_key_path: control-planes/control-plane-%d.pem
  ssh_cert:
  ssh_cert_path:
  labels: {}
  taints: []
EOT
    , 10 + i, 10 + i, var.region, i)]),
    join("\n", [for i in range(var.worker_count) : format(
      <<EOT
- address: 10.0.1.%d
  port: 22
  role:
  - worker
  hostname_override: ip-10-0-1-%d.%s.compute.internal
  user: outscale
  docker_socket: /var/run/docker.sock
  ssh_key:
  ssh_key_path: workers/worker-%d.pem
  ssh_cert:
  ssh_cert_path:
  labels: {}
  taints: []
EOT
    , 19 + i, 19 + i, var.region, i)]),

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
      feature-gates: CSIVolumeFSGroupPolicy=true
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
      feature-gates: CSIVolumeFSGroupPolicy=true
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
  sans: []
  webhook: null
addons:
addons_include:
  - "${path.root}/cloud-provider-osc/secrets.yaml"
  - "https://raw.githubusercontent.com/outscale-dev/cloud-provider-osc/v0.0.9beta/deploy/osc-ccm-manifest.yml"
  - "${path.root}/osc-csi/secrets.yaml"
  - https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
  - https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
  - https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
  - https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
  - https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
system_images:
  etcd: rancher/mirrored-coreos-etcd:v3.4.16-rancher1
  alpine: rancher/rke-tools:v0.1.78
  nginx_proxy: rancher/rke-tools:v0.1.78
  cert_downloader: rancher/rke-tools:v0.1.78
  kubernetes_services_sidecar: rancher/rke-tools:v0.1.78
  kubedns: rancher/mirrored-k8s-dns-kube-dns:1.17.4
  dnsmasq: rancher/mirrored-k8s-dns-dnsmasq-nanny:1.17.4
  kubedns_sidecar: rancher/mirrored-k8s-dns-sidecar:1.17.4
  kubedns_autoscaler: rancher/mirrored-cluster-proportional-autoscaler:1.8.3
  coredns: rancher/mirrored-coredns-coredns:1.8.4
  coredns_autoscaler: rancher/mirrored-cluster-proportional-autoscaler:1.8.3
  nodelocal: rancher/mirrored-k8s-dns-node-cache:1.18.0
  kubernetes: rancher/hyperkube:v1.21.6-rancher1
  flannel: rancher/mirrored-coreos-flannel:v0.14.0
  flannel_cni: rancher/flannel-cni:v0.3.0-rancher6
  calico_node: rancher/mirrored-calico-node:v3.19.2
  calico_cni: rancher/mirrored-calico-cni:v3.19.2
  calico_controllers: rancher/mirrored-calico-kube-controllers:v3.19.2
  calico_ctl: rancher/mirrored-calico-ctl:v3.19.2
  calico_flexvol: rancher/mirrored-calico-pod2daemon-flexvol:v3.19.2
  canal_node: rancher/mirrored-calico-node:v3.19.2
  canal_cni: rancher/mirrored-calico-cni:v3.19.2
  canal_controllers: rancher/mirrored-calico-kube-controllers:v3.19.2
  canal_flannel: rancher/mirrored-coreos-flannel:v0.14.0
  canal_flexvol: rancher/mirrored-calico-pod2daemon-flexvol:v3.19.2
  weave_node: weaveworks/weave-kube:2.8.1
  weave_cni: weaveworks/weave-npc:2.8.1
  pod_infra_container: rancher/mirrored-pause:3.4.1
  ingress: rancher/nginx-ingress-controller:nginx-0.49.3-rancher1
  ingress_backend: rancher/mirrored-nginx-ingress-controller-defaultbackend:1.5-rancher1
  ingress_webhook: rancher/mirrored-ingress-nginx-kube-webhook-certgen:v1.1.1
  metrics_server: rancher/mirrored-metrics-server:v0.5.0
  windows_pod_infra_container: rancher/kubelet-pause:v0.1.6
  aci_cni_deploy_container: noiro/cnideploy:5.1.1.0.1ae238a
  aci_host_container: noiro/aci-containers-host:5.1.1.0.1ae238a
  aci_opflex_container: noiro/opflex:5.1.1.0.1ae238a
  aci_mcast_container: noiro/opflex:5.1.1.0.1ae238a
  aci_ovs_container: noiro/openvswitch:5.1.1.0.1ae238a
  aci_controller_container: noiro/aci-containers-controller:5.1.1.0.1ae238a
  aci_gbp_server_container: noiro/gbp-server:5.1.1.0.1ae238a
  aci_opflex_server_container: noiro/opflex-server:5.1.1.0.1ae238a
ssh_key_path: ~/.ssh/id_rsa
ssh_cert_path:
ssh_agent_auth: false
authorization:
  mode: rbac
  options: {}
ignore_docker_version: null
enable_cri_dockerd: null
kubernetes_version:
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
  name: "external"
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
bastion_host:
  address: ${outscale_public_ip.bastion.public_ip}
  port: 22
  user: outscale
  ssh_key_path: ${path.root}/bastion/bastion.pem
EOT
  )
  depends_on = [local_file.cloud-provider-osc_secrets, local_file.osc-csi_secrets]
}
