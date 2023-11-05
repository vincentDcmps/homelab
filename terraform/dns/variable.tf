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
    "arch",
    "dashboard",
    "drone",
    "file",
    "ghostfolio",
    "git",
    "grafana",
    "hass",
    "jellyfin",
    "jellyfin-vue",
    "paperless-ng",
    "supysonic",
    "syno",
    "torrent",
    "vault",
    "vikunja",
    "www",
    "mail"
  ]
}

variable localEndpoint{
  type= string
  default= "traefik-local.service.consul."
}
variable cloudEndpoint{
  type= string
  default= "135.181.150.203"
}
