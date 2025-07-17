
job "joplin" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  vault {
  }
  group "joplin"{
    network {
      mode = "host"
      port "http" {
        to = 22300
      }
    }
    task "server" {
      driver = "docker"
      service {
        name = "joplin"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      config {
        image = "docker.service.consul:5000/joplin/server:3.4.1"
        ports = ["http"]

      }
      env {
        APP_BASE_URL = "https://${NOMAD_JOB_NAME}.ducamps.eu"
        DB_CLIENT = "pg"
        POSTGRES_DATABASE = "joplin"
        POSTGRES_USER = "joplin"
        POSTGRES_HOST = "db.service.consul"
      }

      template {
        data= <<EOH
          {{ with secret "secrets/data/database/joplin"}}
         POSTGRES_PASSWORD = "{{ .Data.data.password }}"
          {{end}}
          EOH
        destination = "secrets/.env"
        env = true
      }
      resources {
        memory = 300
      }
    }

  }
}
