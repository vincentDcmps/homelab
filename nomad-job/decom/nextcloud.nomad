
job "nextcloud" {
  datacenters = ["homelab"]
  type = "service"
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }


  meta {
    forcedeploy = "2"
  }

  group "nextcloud"{
    network {
      mode = "host"
      port "http" {
        to = 80
      }
    }
    vault{
      policies= ["access-tables"]

    }
    task "server" {
      driver = "docker"
      service {
        name = "nextcloud"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`file.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=file.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}_insecure.entrypoints=web",
            "traefik.http.routers.${NOMAD_JOB_NAME}_insecure.rule=Host(`file.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}_insecure.middlewares=httpsRedirect",
            "traefik.http.middlewares.httpsRedirect.redirectscheme.scheme=https",


        ]
      }
      config {
        image = "nextcloud:latest"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nextcloud/data:/var/www/html/data",
          "/mnt/diskstation/nextcloud/config:/var/www/html/config",
          "/mnt/diskstation/nextcloud/root:/var/www/html/"
        ]

      }
      env {
     }

      template {
        data= <<EOH
          {{ with secret "secrets/data/nextcloud"}}
          POSTGRES_DB="nextcloud"
          POSTGRES_USER="nextcloud"
          POSTGRES_PASSWORD="{{ .Data.data.POSTGRES_PASSWORD }}"
          NEXTCLOUD_ADMIN_USER="vincent"
          NEXTCLOUD_ADMIN_PASSWORD="{{ .Data.data.ADMIN_PASSWORD }}"
          NEXTCLOUD_TRUSTED_DOMAINS="file.ducamps.eu"
          POSTGRES_HOST="active.db.service.consul"
          {{end}}
          EOH
        destination = "secrets/nextcloud.env"
        env = true
      }


    }

  }
}
