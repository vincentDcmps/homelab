
job "supysonic" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  group "supysonic"{
    network {
      mode = "host"
      port "http" {
        to = 5000
      }
    }
    vault{
      policies= ["access-tables"]

    }
    task "server" {
      driver = "docker"
      service {
        name = "supysonic"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "ducampsv/supysonic:latest"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/music:/mnt/diskstation/music"
        ]

      }
      env {
        SUPYSONIC_RUN_MODE= "standalone"
        SUPYSONIC_DAEMON_ENABLED = "true"
        SUPYSONIC_WEBAPP_LOG_LEVEL = "WARNING"
        SUPYSONIC_DAEMON_LOG_LEVEL  = "INFO"
      }

      template {
        data= <<EOH
          {{ with secret "secrets/data/supysonic"}}
            SUPYSONIC_DB_URI = "postgres://supysonic:{{ .Data.data.db_password}}@db1.ducamps.win/supysonic"
          {{end}}
          EOH
        destination = "secrets/supysonic.env"
        env = true
      }
    }

  }
}
