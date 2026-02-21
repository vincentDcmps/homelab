type = "csi"
id = "dms-logs"
name = "dms-logs"
external_id = "dms-logs"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/dms/mail-logs"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
