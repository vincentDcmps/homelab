type = "csi"
id = "registry-ghcr"
name = "registry-ghcr"
plugin_id = "nfs"
capability {
	access_mode = "multi-node-multi-writer"
	attachment_mode = "file-system"
}
context {
  server = "nfs.service.consul"
  share = "/exports/nomad/registry/ghcr"
  mountPermissions = "0"  
}
mount_options {
  fs_type = "nfs"
  mount_flags = [ "timeo=30", "intr", "vers=3", "_netdev" , "nolock" ]
}
