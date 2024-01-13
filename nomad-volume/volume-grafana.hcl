type = "csi"
id = "grafana"
name = "grafana"
plugin_id = "nfs"
external_id = "grafana"
capability {
  access_mode = "multi-node-multi-writer"
  attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/var/local/volume1/nomad/grafana"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "timeo=30", "intr", "vers=3", "_netdev" , "nolock" ]
}
