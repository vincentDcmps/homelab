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
    hcloud_firewall.torrent.id,
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

data "hcloud_image" "arch" {
  with_selector = "os-flavor=archlinux"
  most_recent   = true
  with_status   = ["available"]

}

resource "hcloud_server" "merlin" {
  count       = var.instances
  name        = "merlin"
  image       = data.hcloud_image.arch.id
  server_type = "cx11"
  location    = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [
    hcloud_firewall.prod.id,
    hcloud_firewall.Gitea_SSH.id,
    hcloud_firewall.torrent.id,
    hcloud_firewall.mail.id,
    hcloud_firewall.ssh.id,
  ]
  labels = {
  }

  lifecycle {
    ignore_changes = [
      ssh_keys,
    ]
  }
}
