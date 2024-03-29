type = "csi"
id = "registry-docker"
name = "registry-docker"
external_id = "registry-docker"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/nomad/registry/docker"
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "vers=4" ]
}
