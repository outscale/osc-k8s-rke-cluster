resource "local_file" "ccm_secrets" {
  filename        = "${path.root}/addons/ccm/secrets.yaml"
  file_permission = "0660"
  content         = <<-EOF
apiVersion: v1
kind: Secret
metadata:
  name: osc-secret
  namespace: kube-system
stringData:
  key_id: ${var.access_key_id}
  access_key: ${var.secret_key_id}
  aws_default_region: AWS_DEFAULT_REGION
  aws_availability_zones: AWS_AVAILABILITY_ZONES
  osc_account_id: OSC_ACCOUNT_ID
  osc_account_iam: OSC_ACCOUNT_IAM
  osc_user_id: OSC_USER_ID
  osc_arn: OSC_ARN
EOF
}
