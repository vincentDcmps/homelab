type = "csi"
id = "registry-ghcr"
name = "registry-ghcr"
plugin_id = "nfs"
external_id = "registry-ghcr"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/registry/ghcr"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4"]
}
