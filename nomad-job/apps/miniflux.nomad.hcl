
job "miniflux" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "0"
  }

  group "miniflux"{
    network {
      mode = "host"
      port "http" {
        to = 8080
      }
    }
    vault{
    }
    task "server" {
      driver = "docker"
      service {
        name = "miniflux"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`rss.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=rss.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      config {
        image = "docker.service.consul:5000/miniflux/miniflux:2.2.14"
        ports = ["http"]
      }
      env {
        RUN_MIGRATIONS=1
        POLLING_FREQUENCY=15
        SCHEDULER_ROUND_ROBIN_MIN_INTERVAL=15
        OAUTH2_OIDC_DISCOVERY_ENDPOINT= "https://auth.ducamps.eu"
        OAUTH2_CLIENT_ID="miniflux"
        OAUTH2_OIDC_PROVIDER_NAME="Authelia"
        OAUTH2_PROVIDER="oidc"
        OAUTH2_REDIRECT_URL="https://rss.ducamps.eu/oauth2/oidc/callback"
        OAUTH2_USER_CREATION=1
      }

      template {
        data =  <<EOH
        {{ with secret "secrets/data/database/miniflux"}}
        DATABASE_URL = postgres://miniflux:{{ .Data.data.password}}@active.db.service.consul/miniflux?sslmode=disable
        {{ end }}
        {{ with secret "secrets/data/authelia/miniflux"}}
        OAUTH2_CLIENT_SECRET= {{ .Data.data.password }}
        {{ end }}
        EOH
        destination = "secrets/mini.env"
        env= true
      }
      resources {
        memory = 300
      }
    }

  }
}
