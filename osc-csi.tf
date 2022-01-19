resource "local_file" "osc-csi_secrets" {
  filename        = "${path.root}/osc-csi/secrets.yaml"
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

resource "local_file" "osc-csi_ansible-vars" {
  filename        = "${path.root}/osc-csi/ansible-vars.yaml"
  file_permission = "0660"
  content         = <<-EOF
{
  "region": "${var.region}"
}
EOF
}