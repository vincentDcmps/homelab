
job "seedboxsync" {
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
    cron             = "0,30 * * * *"
    prohibit_overlap = true
  }
  group "seedboxsync" {
    network {
      mode = "host"
    }
    vault {
      policies = ["access-tables"]
    }
    task "server" {
      driver = "docker"
      service {
        name = "lftp"
      }
      config {
        image = "ducampsv/lftp:latest"
        volumes = [
          "/mnt/diskstation/media/download:/media"
        ]
        args = [
          "-u", "${USERNAME},${PASSWORD}",
          "-e", "mirror -c -P 5 -x seed ${REMOTE_PATH} /media;quit",
          "${REMOTE_SERVER}"
        ]

      }
      env {
        USER_ID  = 1000001
        GROUP_ID = 1000007
      }
      template {
        data        = <<EOH
          {{ with secret "secrets/data/seedbox"}}
          USERNAME = "{{ .Data.data.username }}"
          PASSWORD = "{{ .Data.data.password }}"
          REMOTE_PATH = "{{ .Data.data.remote_path }}"
          REMOTE_SERVER = "{{ .Data.data.remote_server }}"
          {{end}}
          EOH
        destination = "secrets/sample.env"
        env         = true
      }
      resources {
        memory = 100
      }
    }

  }
}
