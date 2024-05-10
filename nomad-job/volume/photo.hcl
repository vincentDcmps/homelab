type = "csi"
id = "photo"
name = "photo"
external_id = "photo"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/photo"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
