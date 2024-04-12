type = "csi"
id = "authelia-config"
name = "authelia-config"
external_id = "authelia-config"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/authelia"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
