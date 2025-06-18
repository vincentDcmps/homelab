
job "backup-postgress" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "batch"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }
  periodic {
    crons             = ["0 3 * * *"]
    prohibit_overlap = true
  }
  group "backup-postgress" {
    network {
      mode = "host"
    }
    vault {
    }
    task "backup" {
      driver = "docker"
      service {
        name = "backup-postgress"
      }
      config {
        image = "docker.service.consul:5000/ducampsv/docker-backup-postgres:latest"
        volumes = [
          "/mnt/diskstation/nomad/backup/postgres:/backup"
        ]
      }
      template {
        data        = <<EOH
          {{ with secret "secrets/data/nomad/backup-postgress"}}
          PGUSER = "dump"
          PGPASSWORD = "{{ .Data.data.password }}"
          PGHOST = "active.db.service.consul"
          {{end}}
          EOH
        destination = "secrets/secrets.env"
        env         = true
      }
      resources {
        memory = 180
        memory_max = 400
      }
    }

  }
}
