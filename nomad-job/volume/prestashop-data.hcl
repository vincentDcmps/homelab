type = "csi"
id = "prestashop-data"
name = "prestashop-data"
external_id = "prestashop-data"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/prestashop/data"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
