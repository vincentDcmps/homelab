job "batch-rutorrent" {
  datacenters  = ["hetzner"]
  priority=50
  type="batch"
  meta {
    forcedeploy="0"
  }
  periodic {
    crons = ["0 * * * *"]
    prohibit_overlap = true
  }
  group "batch-rutorrent" {
    task "cleanForwardFolder" {
      driver= "docker"
      config {
        image = "docker.service.consul:5000/library/alpine"
        volumes = [
          "/mnt/hetzner/storagebox/file/forward:/file"
        ]
        command = "find"
        args = [
          "/file",
          "-empty",
          "-type",
          "d",
          "-delete"
        ]
      }
    }
  }
}
