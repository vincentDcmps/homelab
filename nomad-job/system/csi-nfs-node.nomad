job "csi-nfs-nodes" {
  datacenters = ["homelab","hetzner"]
  type = "system"
  group "csi-nfs-nodes" {
    task "plugin" {
      driver = "docker"
      config {
        image = "registry.k8s.io/sig-storage/nfsplugin:v4.12.1"
        args = [
          "--v=5",
          "--nodeid=${attr.unique.hostname}",
          "--endpoint=unix:///csi/csi.sock",
          "--drivername=nfs.csi.k8s.io"
        ]
        # node plugins must run as privileged jobs because they
        # mount disks to the host
        privileged = true
      }
      csi_plugin {
        id        = "nfs"
        type      = "node"
        mount_dir = "/csi"
      }
      resources {
        memory = 50
      }
    }
  }
}
