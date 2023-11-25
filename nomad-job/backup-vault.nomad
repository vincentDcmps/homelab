
job "backup-vault" {
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
  group "backup-vault" {
    network {
      mode = "host"
    }
    vault {
      policies = ["vault-backup"]
    }
    task "backup-vault" {
      driver = "docker"
      config {
        image = "ducampsv/docker-vault-backup:latest"
        volumes = [
          "/mnt/diskstation/git/backup/vault:/backup"
        ]
      }
      template {
        data        = <<EOH
          {{ with secret "secrets/data/nomad/vault-backup"}}
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
