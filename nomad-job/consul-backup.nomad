
job "consul-backup" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "batch"
  meta {
    forcedeploy = "0"
  }

  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }
  periodic {
    crons             = ["30 3 * * *"]
    prohibit_overlap = true
  }
  group "consul-backup" {
    network {
      mode = "host"
    }
    task "consul-backup" {
      driver = "docker"
      config {
        image = "ducampsv/docker-consul-backup:latest"
        volumes = [
          "/mnt/diskstation/git/backup/consul:/backup"
        ]
      }
      resources {
        memory = 100
      }
    }

  }
}
