locals {
  defaultCname=hcloud_server.HomeLab2[0].name
}

resource "hetznerdns_zone" "externalZone" {
  name = "ducamps.win"
  ttl  = 1700
}


resource "hetznerdns_record" "rootalias" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "@"
  value   = hcloud_server.HomeLab2[0].ipv4_address
  type    = "A"
}
resource "hetznerdns_record" "MX1" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "@"
  value   = "20 spool.mail.gandi.net."
  type    = "MX"
}
resource "hetznerdns_record" "MX2" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "@"
  value   = "50 fb.mail.gandi.net"
  type    = "MX"
}

resource "hetznerdns_record" "spf" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "@"
  value   = "\"v=spf1 include:_mailcust.gandi.net ~all\""
  type    = "TXT"
}
resource "hetznerdns_record" "caldav" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "_caldavs_tcp"
  value   = "10 20 443 www.${hetznerdns_zone.externalZone.name}"
  type    = "SRV"
}
resource "hetznerdns_record" "carddavs" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "_carddavs_tcp"
  value   = "10 20 443 www.${hetznerdns_zone.externalZone.name}"
  type    = "SRV"
}
resource "hetznerdns_record" "server" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = local.defaultCname
  value   = hcloud_server.HomeLab2[0].ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "dendrite" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "dendrite"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "diskstation" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "diskstation"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "drone" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "drone"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "file" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "file"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "ghostfolio" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "ghostfolio"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "git" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "git"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "grafana" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "grafana"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "hass" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "hass"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "jellyfin" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "jellyfin"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "supysonic" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "supysonic"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "syno" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "syno"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "vault" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "vault"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "vikunja" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "vikunja"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "www" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "www"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "ww" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "ww"
  value   = local.defaultCname
  type    = "CNAME"
}

resource "hetznerdns_record" "gm1" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "gm1._domainkey"
  value   = "gm1.gandimail.net"
  type    = "CNAME"
}

resource "hetznerdns_record" "gm2" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "gm2._domainkey"
  value   = "gm2.gandimail.net"
  type    = "CNAME"
}

resource "hetznerdns_record" "gm3" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "gm3._domainkey"
  value   = "gm3.gandimail.net"
  type    = "CNAME"
}


resource "hetznerdns_record" "imap" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "imap"
  value   = "mail.gandi.net."
  type    = "CNAME"
}

resource "hetznerdns_record" "smtp" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "smtp"
  value   = "mail.gandi.net"
  type    = "CNAME"
}



