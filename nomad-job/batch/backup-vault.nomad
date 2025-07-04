
job "backup-vault" {
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
    crons             = ["30 3 * * *"]
    prohibit_overlap = true
  }
  group "backup-vault" {
    network {
      mode = "host"
    }
    vault {
    }
    task "backup-vault" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/ducampsv/docker-vault-backup:latest"
        volumes = [
          "/mnt/diskstation/nomad/backup/vault:/backup"
        ]
      }
      template {
        data        = <<EOH
          {{ with secret "secrets/data/nomad/backup-vault"}}
          VAULT_APPROLEID = "{{ .Data.data.VAULT_APPROLEID }}"
          VAULT_SECRETID  = "{{ .Data.data.VAULT_SECRETID }}"
          {{end}}
        EOH
        destination = "secrets/secrets.env"
        env         = true
      }
      resources {
        memory = 100
      }
    }

  }
}
