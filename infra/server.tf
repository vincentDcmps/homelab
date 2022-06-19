resource "hcloud_server" "HomeLab" {
  count       = var.instances
  name        = "merlin"
  image       = var.os_type
  server_type = var.server_type
  location    = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  labels = {
  }

}
