resource "powerdns_record" "Cname" {
  for_each = toset(var.cnameList)
    zone    = powerdns_zone.ducampseu.name
    name    = "${each.key}.${powerdns_zone.ducampseu.name}"
    type    = "CNAME"
    ttl     = 1700
    records = [var.localEndpoint]
}

resource "hetznerdns_record" "Cname" {
  for_each = var.enableHetzner ? toset(var.cnameList) : []

  zone_id = hetznerdns_zone.externalZoneEU[0].id
  name    = each.key
  value   = var.cloudEndpoint
  type    = "A"
}
