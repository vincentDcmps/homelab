resource "hcloud_firewall" "HomeLab" {
  name= "firewall-1"
  rule {
    direction ="in"
    protocol = "tcp"
    port = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction ="in"
    protocol = "tcp"
    port = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  # torrent UDH port
  rule {
    direction ="in"
    protocol = "udp"
    port = "6881"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  # wireguard port
  rule {
    direction ="in"
    protocol = "udp"
    port = "51820"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]

  }
# torrent listen port
  rule {
    direction ="in"
    protocol = "tcp"
    port = "50000"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]

  }
  rule {
    direction ="in"
    protocol = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  #  rule {
  #  direction = "in"
  #  protocol = "tcp"
  #  port = "22"
  #  source_ips = [
  #    "0.0.0.0/0",
  #    "::/0"
  #  ]
  #}
}
