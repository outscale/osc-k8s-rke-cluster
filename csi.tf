resource "local_file" "csi_secrets" {
  filename        = "${path.root}/addons/csi/secrets.yaml"
  file_permission = "0660"
  content         = <<-EOF
apiVersion: v1
kind: Secret
metadata:
  name: osc-csi-bsu
  namespace: kube-system
stringData:
  access_key: ${var.access_key_id}
  secret_key: ${var.secret_key_id}
EOF
}

resource "local_file" "csi_ansible_vars" {
  filename        = "${path.root}/addons/csi/ansible-vars.yaml"
  file_permission = "0660"
  content         = <<-EOF
{
  "region": "${var.region}"
}
EOF
}
