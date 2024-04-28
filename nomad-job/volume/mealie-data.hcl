type = "csi"
id = "mealie-data"
name = "mealie-data"
external_id = "mealie-data"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/mealie"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
