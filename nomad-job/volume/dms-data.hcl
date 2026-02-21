type = "csi"
id = "dms-data"
name = "dms-data"
external_id = "dms-data"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/dms/mail-data"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
