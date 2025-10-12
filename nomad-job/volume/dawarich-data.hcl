type = "csi"
id = "dawarich-data"
name = "dawarich-data"
external_id = "dawarich-data"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/dawarich/data"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
