variable powerDnsApiKey {
  type= string
  sensitive= true
}
variable hetznerApiKey {
  type= string
  sensitive= true
}
variable enableHetzner {
 type= bool
 default = true
}
variable powerDnsURL {
  type=string
  default="http://192.168.1.5:8081"
}
variable cnameList{
  type=list
  default= [
    "auth",
    "arch",
    "budget",
    "dashboard",
    "drone",
    "file",
    "ghostfolio",
    "git",
    "grafana",
    "hass",
    "immich",
    "jellyfin",
    "jellyfin-vue",
    "ldap",
    "mail",
    "mealie",
    "paperless",
    "supysonic",
    "syno",
    "torrent",
    "vault",
    "vikunja",
    "www",
  ]
}

variable localEndpoint{
  type= string
  default= "traefik-local.service.consul."
}
variable cloudEndpoint{
  type= string
  default= "65.21.2.14"
}
