type = "csi"
id = "immich-cache"
name = "immich-cache"
external_id = "immich-cache"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/immich/cache"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
