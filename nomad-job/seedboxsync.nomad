
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
      policies = ["seedbox"]
    }
    task "rsync" {
      driver = "docker"
      service {
        name = "seedboxsync"
      }
      config {
        image = "ducampsv/rsync:latest"
        volumes = [
          "/mnt/diskstation/media/download:/media",
          "local/id_rsa:/home/rsyncuser/.ssh/id_rsa"
        ]
        command = "rsync"
        args = [
          "--info=progress2",
          "-e" ,  "ssh -p23 -o StrictHostKeyChecking=no",
          "-a",
          "${USERNAME}@${REMOTE_SERVER}:${REMOTE_PATH}",
          "/media",
          "--exclude=seed",
          "-v"
        ]
      }
      env {
        RSYNC_UID  = 1000001
        RSYNC_GID = 1000007
      }
      template {
        data        = <<EOH
          {{ with secret "secrets/data/nomad/seedbox"}}
          USERNAME = "{{ .Data.data.username }}"
          REMOTE_PATH = "{{ .Data.data.remote_rsync_path }}"
          REMOTE_SERVER = "{{ .Data.data.remote_server }}"
          {{end}}
          EOH
        destination = "secrets/sample.env"
        env         = true
      }
      template {
        data = "{{ with secret \"secrets/data/nomad/seedbox\"}}{{ .Data.data.private_key }}{{end}}"

        destination = "local/id_rsa"
        uid=1000001
        perms= "600"

      }
      resources {
        memory = 500
      }
    }

  }
}
