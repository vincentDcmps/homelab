resource "powerdns_zone" "ducampseu" {
  name        = "ducamps.eu."
  kind        = "Native"
}

resource "powerdns_zone" "landucampseu" {
  name        = "lan.ducamps.eu."
  kind        = "Native"
}

resource "powerdns_zone" "reversezone" {
  name        = "1.168.192.in-addr.arpa."
  kind        = "Native"
}

resource "hetznerdns_zone" "externalZoneEU" {
    count = var.enableHetzner ? 1 : 0
    name = "ducamps.eu"
    ttl  = 1700
}
