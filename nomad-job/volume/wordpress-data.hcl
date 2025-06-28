type = "csi"
id = "wordpress-data"
name = "wordpress-data"
external_id = "wordpress-data"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/wordpress/data"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
