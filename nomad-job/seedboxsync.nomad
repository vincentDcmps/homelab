
job "seedboxsync" {
  datacenters = ["homelab"]
  priority = 50
  type = "batch"
  meta {
    forcedeploy = "0"
  }
  #  constraint {
  #}

  periodic {
    cron = "0,30 * * * *"  
    prohibit_overlap = true
  }
  group "seedboxsync"{
    network {
      mode = "host"
    }
    vault{
      policies= ["access-tables"]
    }
    task "server" {
      driver = "docker"
      service {
        name = "lftp"
      }
      config {
        image = "minidocks/lftp"
        volumes = [
          "/mnt/diskstation/media/download:/media"
        ]
        args=[
          "-u" ,"${USERNAME},${PASSWORD}",
          "-e" ,"mirror -c -P 5 -x seed ${REMOTE_PATH} /media;quit",
          "${REMOTE_SERVER}"
        ]

      }

      template {
        data= <<EOH
          {{ with secret "secrets/data/seedbox"}}
          USERNAME = "{{ .Data.data.username }}"
          PASSWORD = "{{ .Data.data.password }}"
          REMOTE_PATH = "{{ .Data.data.remote_path }}"
          REMOTE_SERVER = "{{ .Data.data.remote_server }}"
          {{end}}
          EOH
        destination = "secrets/sample.env"
        env = true
      }
      resources {
        memory = 50
      }
    }

  }
}