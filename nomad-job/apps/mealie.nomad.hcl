
job "mealie" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "mealie" {
    network {
      mode = "host"
      port "http" {
        to = 9000
      }
    }
    volume "mealie-data" {
      type            = "csi"
      source          = "mealie-data"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    vault {

    }
    task "mealie-server" {
      driver = "docker"
      service {
        name = "mealie"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=Mealie",
          "homer.service=Application",
          "homer.subtitle=Mealie",
          "homer.logo=https://mealie.ducamps.eu/favicon.ico",
          "homer.target=_blank",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
        ]
      }
      config {
        image = "ghcr.service.consul:5000/mealie-recipes/mealie:v3.4.0"
        ports = ["http"]
      }
      volume_mount {
        volume      = "mealie-data"
        destination = "/app/data"
      }
      env {
        ALLOW_PASSWORD_LOGIN   = "false"
        PUID                   = "1000001"
        PGID                   = "1000001"
        TZ                     = "Europe/Paris"
        MAX_WORKERS            = 1
        WEB_CONCURRENCY        = 1
        BASE_URL               = "https://mealie.ducamps.eu"
        OIDC_USER_GROUP        = "MealieUsers"
        OIDC_ADMIN_GROUP       = "MealieAdmins"
        OIDC_AUTH_ENABLED      = "True"
        OIDC_SIGNUP_ENABLED    = "true"
        OIDC_CONFIGURATION_URL = "https://auth.ducamps.eu/.well-known/openid-configuration"
        OIDC_CLIENT_ID         = "mealie"
        OIDC_AUTO_REDIRECT     = "false"
        OIDC_PROVIDER_NAME     = "authelia"
        DB_ENGINE              = "postgres"
        POSTGRES_USER          = "mealie"
        POSTGRES_SERVER        = "active.db.service.consul"
        POSTGRES_PORT          = 5432
        POSTGRES_DB            =  "mealie"
        LOG_LEVEL              = "DEBUG"
      }
      template {
        data        = <<EOH
{{ with secret "secrets/data/database/mealie"}}POSTGRES_PASSWORD= "{{ .Data.data.password }}" {{end}}
{{ with secret "secrets/data/authelia/mealie"}}OIDC_CLIENT_SECRET= "{{ .Data.data.password }}" {{end}}
{{ with secret "secrets/data/nomad/mealie"}}OPENAI_API_KEY= "{{ .Data.data.openai }}" {{end}}
          EOH
        destination = "secrets/var.env"
        env         = true
      }
      resources {
        memory = 400
        memory_max = 800
      }
    }

  }
}
