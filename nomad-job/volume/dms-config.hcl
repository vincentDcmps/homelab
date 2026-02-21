type = "csi"
id = "dms-config"
name = "dms-config"
external_id = "dms-config"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/dms/config"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
