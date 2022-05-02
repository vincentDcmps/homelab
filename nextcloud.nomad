
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
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`file.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=file.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "nextcloud:latest"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nextcloud/data:/var/www/html/data",
          "/mnt/diskstation/nextcloud/config:/var/www/html/config",
          "local/default:/config/nginx/site-confs/default"
        ]

      }
      env {
     }

      template {
        data= <<EOH
          {{ with secret "secrets/data/nextcloud"}}
          POSTGRES_DB="nextcloud2"
          POSTGRES_USER="nextcloud"
          POSTGRES_PASSWORD="{{ .Data.data.POSTGRES_PASSWORD }}"
          NEXTCLOUD_ADMIN_USER="vincent"
          NEXTCLOUD_ADMIN_PASSWORD="{{ .Data.data.ADMIN_PASSWORD }}"
          NEXTCLOUD_TRUSTED_DOMAINS="file.ducamps.win"
          POSTGRES_HOST="db1.ducamps.win"
          {{end}}
          EOH
        destination = "secrets/nextcloud.env"
        env = true
      }


    }

  }
}
