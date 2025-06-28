type = "csi"
id = "prestashop-sql"
name = "prestashop-sql"
external_id = "prestashop-sql"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/prestashop/sql"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
