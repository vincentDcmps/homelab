locals {
  defaultCname=hcloud_server.HomeLab2[0].name
}

resource "hetznerdns_zone" "externalZone" {
  name = "ducamps.win"
  ttl  = 1700
}

resource "hetznerdns_zone" "externalZoneEU" {
    name = "ducamps.eu"
    ttl  = 1700
}

resource "hetznerdns_record" "MX1Eu" {
    zone_id = hetznerdns_zone.externalZoneEU.id
    name    = "@"
    value   = "20 mail"
    type    = "MX"
}

resource "hetznerdns_record" "mailEu" {
      zone_id = hetznerdns_zone.externalZoneEU.id
      name    = "mail"
      value    = local.defaultCname
      type= "CNAME"
}
resource "hetznerdns_record" "serverEU" {
  zone_id = hetznerdns_zone.externalZoneEU.id
  name    = local.defaultCname
  value   = hcloud_server.HomeLab2[0].ipv4_address
  type    = "A"
}
resource "hetznerdns_record" "spfEu" {
  zone_id = hetznerdns_zone.externalZoneEU.id
  name    = "@"
  value   = "\"v=spf1 ip4:${hcloud_server.HomeLab2[0].ipv4_address} ~all\""
  type    = "TXT"
}

resource "hetznerdns_record" "dkimRecordEu" {
  zone_id = hetznerdns_zone.externalZoneEU.id
  name    = "mail._domainkey"
  value   = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0GadPljh+zM+Hf8MAf2wyj+h9p72aBFeFaiDhnswxO68fM9Uk6XhN4s1BkHLY5AWQh0SP1JDBaFWDfJiOV/27E3qJIa4KDHPZcgxgvo+SbfgNZq5qGIhKyqAAtyg/dI8IMKVOZ5Cevdv9VFrSF84xnTmDBCrWydPyV8D5+xA/bVna/AVCAVUeXVppyMPpC0s1HpRNJ0YaY23RH1KwChxvZY+BkanELSzTA8K0ATbIzwgQaK10/lc1S6EFvaSNG8sy6EIoondl6t+uiqU3bHgAW68r8snzl2gclG+uMkjXkH7YGPJzL9Co1o1MlKOHIONz89CCe0puIH4qaCo1G6EDwIDAQAB\""
  type    = "TXT"
}

resource "hetznerdns_record" "dmarcEU" {

  zone_id = hetznerdns_zone.externalZoneEU.id
  name = "_dmarc"
  value = "\"v=DMARC1; p=none; rua=mailto:vincent@ducamps.eu; ruf=mailto:vincent@ducamps.eu; sp=none; ri=86400\""
  type  = "TXT"
}

resource "hetznerdns_record" "imapsAutodiscoverEU" {
  zone_id = hetznerdns_zone.externalZoneEU.id
  name = "_imaps._tcp"
  value = "0 0 993 mail.ducamps.eu"
  type  = "SRV"
}

resource "hetznerdns_record" "submissionAutodiscoverEU" {
  zone_id = hetznerdns_zone.externalZoneEU.id
  name = "_submission._tcp"
  value = "0 0 465 mail.ducamps.eu"
  type  = "SRV"
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
  value   = "50 fb.mail.gandi.net."
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
  value   = "10 20 443 www.${hetznerdns_zone.externalZone.name}."
  type    = "SRV"
}
resource "hetznerdns_record" "carddavs" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "_carddavs_tcp"
  value   = "10 20 443 www.${hetznerdns_zone.externalZone.name}."
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
  value   = "gm1.gandimail.net."
  type    = "CNAME"
}

resource "hetznerdns_record" "gm2" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "gm2._domainkey"
  value   = "gm2.gandimail.net."
  type    = "CNAME"
}

resource "hetznerdns_record" "gm3" {
  zone_id = hetznerdns_zone.externalZone.id
  name    = "gm3._domainkey"
  value   = "gm3.gandimail.net."
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
  value   = "mail.gandi.net."
  type    = "CNAME"
}



