type = "csi"
id = "traefik-data"
name = "traefik-data"
external_id = "traefik-data"
plugin_id = "nfs"
capability {
  access_mode = "multi-node-multi-writer"
  attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/traefik/"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
