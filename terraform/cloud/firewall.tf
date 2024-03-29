resource "hcloud_firewall" "prod" {
  name= "prod"
   
  rule {
    direction ="in"
    protocol = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction ="in"
    protocol = "udp"
    port = "51820"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
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
}


resource "hcloud_firewall" "torrent" {
  name = "torrent"
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
    protocol = "udp"
    port = "6881"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "ssh" {
  name= "ssh"
  rule {
    direction ="in"
    protocol = "tcp"
    port="22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "Gitea_SSH" {
  name= "Gitea SSH"
  rule {
    direction ="in"
    protocol = "tcp"
    port="2222"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
resource "hcloud_firewall" "mail" {
    name= "mail"
    rule {
        direction ="in"
        protocol = "tcp"
        port="25"
        source_ips = [
              "0.0.0.0/0",
                    "::/0"
        ]
      }
    rule {
        direction ="in"
        protocol = "tcp"
        port="993"
        source_ips = [
              "0.0.0.0/0",
                    "::/0"
        ]
      }
    rule {
        direction ="in"
        protocol = "tcp"
        port="465"
        source_ips = [
              "0.0.0.0/0",
                    "::/0"
        ]
      }

}
