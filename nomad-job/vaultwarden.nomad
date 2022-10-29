
job "vaultwarden" {
  datacenters = ["homelab"]
  type        = "service"
  meta {
    forcedeploy = "0"
  }

  group "vaultwarden" {
    network {
      mode = "host"
      port "http" {
        to = 80
      }
    }
    vault {
      policies = ["access-tables"]

    }
    task "vaultwarden" {
      driver = "docker"
      service {
        name = "vaultwarden"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=VaultWarden",
          "homer.service=Application",
          "homer.logo=https://yunohost.org/user/images/bitwarden_logo.png",
          "homer.target=_blank",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.win",

          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`vault.ducamps.win`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=vault.ducamps.win",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
        ]
        check {
          type     = "http"
          path     = "/"
          interval = "60s"
          timeout  = "20s"

          check_restart {
            limit = 3
            grace = "240s"
          }
        }
      }
      config {
        image = "vaultwarden/server"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/vaultwarden:/data"
        ]

      }
      env {
        DATA_FOLDER       = "/data"
        WEB_VAULT_ENABLED = "true"
        DOMAIN            = "https://vault.ducamps.win"

      }

      template {
        data        = <<EOH
          {{ with secret "secrets/data/vaultwarden"}}
          DATABASE_URL=postgresql://vaultwarden:{{ .Data.data.DB_PASSWORD }}@db1.ducamps.win/vaultwarden
          {{end}}
          EOH
        destination = "secrets/vaultwarden.env"
        env         = true
      }
      resources {
        memory = 150
      }
    }

  }
}
