resource "hcloud_server" "HomeLab2" {
  count       = var.instances
  name        = "corwin"
  image       = var.os_type
  server_type = var.server_type
  location    = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [
    hcloud_firewall.prod.id,
    hcloud_firewall.Gitea_SSH.id,
    hcloud_firewall.mail.id,
  ]
  labels = {
  }

  lifecycle {
    ignore_changes = [
      ssh_keys,
    ]
  }
}
