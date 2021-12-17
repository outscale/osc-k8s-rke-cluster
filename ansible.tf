resource "local_file" "ansible-hosts" {
  filename        = "${path.root}/ansible_hosts"
  file_permission = "0660"
  content = format("%s\n\n[control_planes]\n%s\n\n[workers]\n%s",
    "bastion ansible_connection=ssh ansible_ssh_common_args=\"-F ssh_config\"",
    join("\n", [for i in range(var.control_plane_count) : format("control-plane-%d ansible_connection=ssh ansible_ssh_common_args=\"-F ssh_config\"", i)]),
    join("\n", [for i in range(var.worker_count) : format("worker-%d ansible_connection=ssh ansible_ssh_common_args=\"-F ssh_config\"", i)])
  )
}
