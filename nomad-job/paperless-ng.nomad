
job "paperless-ng" {
  datacenters = ["homelab"]
  priority    = 70
  type        = "service"
  meta {
    forcedeploy = "0"
  }

  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "paperless-ng" {
    network {
      mode = "host"
      port "http" {
        to = 8000
      }
      port "redis" {
        to = 6379
      }
    }
    vault {
      policies = ["paperless"]

    }
    task "redis" {
      driver = "docker"
      config {
        image = "redis"
        ports = ["redis"]
      }
      resources {
        memory = 100
      }
    }
    task "paperless-ng" {
      driver = "docker"
      service {
        name = "${JOB}"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "homer.enable=true",
          "homer.name=Paperless",
          "homer.service=Application",
          "homer.logo=https://${NOMAD_JOB_NAME}.ducamps.win/static/frontend/fr-FR/apple-touch-icon.png",
          "homer.target=_blank",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.win",
        ]
        check {
          type     = "http"
          name     = "paperless-ng_health"
          path     = "/"
          interval = "30s"
          timeout  = "5s"
        }
      }
      config {
        image = "ghcr.io/paperless-ngx/paperless-ngx"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/paperless-ng/media:/usr/src/paperless/media",
          "/mnt/diskstation/nomad/paperless-ng/data:/usr/src/paperless/data",
          "/mnt/diskstation/nomad/paperless-ng/export:/usr/src/paperless/export",
          "/mnt/diskstation/nomad/paperless-ng/consume:/usr/src/paperless/consume",
        ]

      }
      env {
        PAPERLESS_REDIS            = "redis://${NOMAD_ADDR_redis}"
        PAPERLESS_DBHOST           = "db1.ducamps.win"
        PAPERLESS_DBNAME           = "paperless"
        PAPERLESS_DBUSER           = "paperless"
        PAPERLESS_OCR_LANGUAGE     = "fra"
        PAPERLESS_CONSUMER_POLLING = "60"
        PAPERLESS_URL              = "https://${NOMAD_JOB_NAME}.ducamps.win"
        PAPERLESS_ALLOWED_HOSTS    = "192.168.1.42,192.168.1.40"
      }

      template {
        data        = <<EOH
          PAPERLESS_DBPASS= {{ with secret "secrets/data/database/paperless"}}{{.Data.data.password }}{{end}}
          EOH
        destination = "secrets/paperless.env"
        env         = true
      }
      resources {
        memory = 800
        cpu    = 2000
      }
    }

  }
}
