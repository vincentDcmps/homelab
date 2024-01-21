resource "hetznerdns_record" "MX1Eu" {
    count = var.enableHetzner ? 1 : 0
    zone_id = hetznerdns_zone.externalZoneEU[0].id
    name    = "@"
    value   = "20 mail"
    type    = "MX"
}

resource "hetznerdns_record" "spfEu" {
  count = var.enableHetzner ? 1 : 0
  zone_id = hetznerdns_zone.externalZoneEU[0].id
  name    = "@"
  value   = "\"v=spf1 ip4:${var.cloudEndpoint} ~all\""
  type    = "TXT"
}

resource "hetznerdns_record" "dkimRecordEu" {
  count = var.enableHetzner ? 1 : 0
  zone_id = hetznerdns_zone.externalZoneEU[0].id
  name    = "mail._domainkey"
  value   = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0GadPljh+zM+Hf8MAf2wyj+h9p72aBFeFaiDhnswxO68fM9Uk6XhN4s1BkHLY5AWQh0SP1JDBaFWDfJiOV/27E3qJIa4KDHPZcgxgvo+SbfgNZq5qGIhKyqAAtyg/dI8IMKVOZ5Cevdv9VFrSF84xnTmDBCrWydPyV8D5+xA/bVna/AVCAVUeXVppyMPpC0s1HpRNJ0YaY23RH1KwChxvZY+BkanELSzTA8K0ATbIzwgQaK10/lc1S6EFvaSNG8sy6EIoondl6t+uiqU3bHgAW68r8snzl2gclG+uMkjXkH7YGPJzL9Co1o1MlKOHIONz89CCe0puIH4qaCo1G6EDwIDAQAB\""
  type    = "TXT"
}

resource "hetznerdns_record" "dmarcEU" {
  count = var.enableHetzner ? 1 : 0
  zone_id = hetznerdns_zone.externalZoneEU[0].id
  name = "_dmarc"
  value = "\"v=DMARC1; p=none; rua=mailto:vincent@ducamps.eu; ruf=mailto:vincent@ducamps.eu; sp=none; ri=86400\""
  type  = "TXT"
}

resource "hetznerdns_record" "imapsAutodiscoverEU" {
  count = var.enableHetzner ? 1 : 0
  zone_id = hetznerdns_zone.externalZoneEU[0].id
  name = "_imaps._tcp"
  value = "0 0 993 mail.ducamps.eu"
  type  = "SRV"
}

resource "hetznerdns_record" "submissionAutodiscoverEU" {
  count = var.enableHetzner ? 1 : 0
  zone_id = hetznerdns_zone.externalZoneEU[0].id
  name = "_submission._tcp"
  value = "0 0 465 mail.ducamps.eu"
  type  = "SRV"
}
resource "hetznerdns_record" "caldavs" {
    count = var.enableHetzner ? 1 : 0
    zone_id = hetznerdns_zone.externalZoneEU[0].id
    name = "_caldavs_tcp"
    value = "10 20 443 www.ducamps.eu"
    type  = "SRV"
}
resource "hetznerdns_record" "carddavs" {
      count = var.enableHetzner ? 1 : 0
      zone_id = hetznerdns_zone.externalZoneEU[0].id
      name = "_carddavs_tcp"
      value = "10 20 443 www.ducamps.eu"
      type  = "SRV"
}
resource "hetznerdns_record" "NSEU" {
    count = var.enableHetzner ? 1 : 0
    zone_id = hetznerdns_zone.externalZoneEU[0].id
    name    = "@"
    value   = "hydrogen.ns.hetzner.com."
    type    = "NS"
}

resource "hetznerdns_record" "rootalias" {
  count = var.enableHetzner ? 1 : 0
  zone_id = hetznerdns_zone.externalZoneEU[0].id
  name    = "@"
  value   = var.cloudEndpoint
  type    = "A"
}

resource "powerdns_record" "mail" {
  zone= powerdns_zone.ducampseu.name
  type= "MX"
  name= powerdns_zone.ducampseu.name
  ttl= 1700
  records = ["10 ${var.localEndpoint}"]
}

resource "powerdns_record" "merlin" {
    zone= powerdns_zone.landucampseu.name
    type= "A"
    name= "merlin.lan.${powerdns_zone.ducampseu.name}"
    ttl= 1700
    records = ["10.0.0.4"]
}
resource "powerdns_record" "corwin" {
    zone= powerdns_zone.landucampseu.name
    type= "A"
    name= "corwin.lan.${powerdns_zone.ducampseu.name}"
    ttl= 1700
    records = ["10.0.0.1"]
}

resource "powerdns_record" "gerard" {
    zone= powerdns_zone.landucampseu.name
    type= "A"
    name= "gerard.lan.${powerdns_zone.ducampseu.name}"
    ttl= 1700
    records = ["192.168.1.41"]
}

resource "powerdns_record" "diskstation" {
      zone= powerdns_zone.landucampseu.name
      type= "A"
      name= "diskstation.lan.${powerdns_zone.ducampseu.name}"
      ttl= 1700
      records = ["192.168.1.10"]
}
