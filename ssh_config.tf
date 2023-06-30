resource "local_file" "ssh_config" {
  filename        = "${path.root}/ssh_config"
  file_permission = "0660"
  content = format("%s\n\n%s\n\n%s\n",
    format("Host bastion\n     HostName %s\n     User outscale\n     IdentityFile bastion/bastion.pem\n     IdentitiesOnly yes\n     UserKnownHostsFile known_hosts\n     StrictHostKeyChecking yes", outscale_public_ip.bastion.public_ip),
    join("\n\n", [for i in range(var.control_plane_count) : format("Host control-plane-%d\n     %s     User outscale\n     IdentityFile control-planes/control-plane-%s.pem\n     IdentitiesOnly yes\n     UserKnownHostsFile known_hosts\n     StrictHostKeyChecking yes", i, var.public_cloud ? format("HostName %s\n", outscale_public_ip.control-planes[i].public_ip) : format("HostName 10.0.1.%d\n     ProxyJump bastion\n", 10 + i), i)]),
    join("\n\n", [for i in range(var.worker_count) : format("Host worker-%d\n     %s     User outscale\n     IdentityFile workers/worker-%s.pem\n     IdentitiesOnly yes\n     UserKnownHostsFile known_hosts\n     StrictHostKeyChecking yes", i, var.public_cloud ? format("HostName %s\n", outscale_public_ip.workers[i].public_ip) : format("HostName 10.0.1.%d\n     ProxyJump bastion\n", 19 + i), i)])
  )
}

resource "local_file" "known_hosts" {
  filename        = "known_hosts"
  file_permission = "0660"
  content = format("%s%s%s%s",
    // bastion
    format("%s %s", outscale_public_ip.bastion.public_ip, tls_private_key.bastion-sshd.public_key_openssh),
    var.public_cloud ? "" : format("10.0.0.10 %s", tls_private_key.bastion-sshd.public_key_openssh),
    // control planes
    var.public_cloud ? join("", [for i in range(var.control_plane_count) : format("%s %s", outscale_public_ip.control-planes[i].public_ip, tls_private_key.control-planes-sshd[i].public_key_openssh)]) :
    join("", [for i in range(var.control_plane_count) : format("10.0.1.%d %s", 10 + i, tls_private_key.control-planes-sshd[i].public_key_openssh)]),
    // workers
    var.public_cloud ? join("", [for i in range(var.worker_count) : format("%s %s", outscale_public_ip.workers[i].public_ip, tls_private_key.workers-sshd[i].public_key_openssh)]) :
    join("", [for i in range(var.worker_count) : format("10.0.1.%d %s", 19 + i, tls_private_key.workers-sshd[i].public_key_openssh)])
  )
  depends_on = [local_file.ssh_config]
}
