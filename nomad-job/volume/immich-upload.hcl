type = "csi"
id = "immich-upload"
name = "immich-upload"
external_id = "immich-upload"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/immich/upload"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
