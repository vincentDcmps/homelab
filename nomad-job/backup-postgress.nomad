
job "backup-postgress" {
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
    cron             = "0 3 * * *"
    prohibit_overlap = true
  }
  group "backup-postgress" {
    network {
      mode = "host"
    }
    vault {
      policies = ["dump"]
    }
    task "backup" {
      driver = "docker"
      service {
        name = "backup-postgress"
      }
      config {
        image = "ducampsv/docker-backup-postgres:latest"
        volumes = [
          "/mnt/diskstation/git/backup/postgres:/backup"
        ]
      }
      template {
        data        = <<EOH
          {{ with secret "secrets/data/database/dump"}}
          PGUSER = "dump"
          PGPASSWORD = "{{ .Data.data.password }}"
          PGHOST = "db1.ducamps.win"
          {{end}}
          EOH
        destination = "secrets/secrets.env"
        env         = true
      }
      resources {
        memory = 50
      }
    }

  }
}
