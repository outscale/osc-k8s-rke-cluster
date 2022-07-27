resource "outscale_internet_service" "internet_service" {
  count = var.public_cloud ? 0 : 1
}

resource "outscale_internet_service_link" "internet_service_link" {
  count               = var.public_cloud ? 0 : 1
  internet_service_id = outscale_internet_service.internet_service[0].internet_service_id
  net_id              = outscale_net.net[0].net_id
}
