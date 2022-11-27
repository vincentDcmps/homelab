
job "vikunja" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "0"
  }

  group "vikunja"{
    network {
      mode = "host"
      port "front" {
        to = 80
      }
      port "api" {
        to = 3456
      }
    }
    vault{
      policies= ["vikunja"]

    }
    task "api" {
      driver = "docker"
      service {
        name = "vikunja-api"
        port = "api"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`) && PathPrefix(`/api/v1`, `/dav/`, `/.well-known/`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.tls.certresolver=myresolver",
        ]
      }
      config {
        image = "vikunja/api"
        ports = ["api"]
      }
      env {
        VIKUNJA_DATABASE_HOST = "db1.ducamps.win"
        VIKUNJA_DATABASE_TYPE = "postgres"
        VIKUNJA_DATABASE_USER = "vikunja"
        VIKUNJA_DATABASE_DATABASE = "vikunja"
        VIKUNJA_SERVICE_JWTSECRET = uuidv4()
        VIKUNJA_SERVICE_FRONTENDURL = "https://${NOMAD_JOB_NAME}.ducamps.win/"
      }

      template {
        data= <<EOH
          {{ with secret "secrets/data/database/vikunja"}}
            VIKUNJA_DATABASE_PASSWORD= "{{ .Data.data.password }}"
          {{end}}
          EOH
        destination = "secrets/sample.env"
        env = true
      }
      resources {
        memory = 50
      }
    }
    task "front" {
      driver = "docker"
      service {
        name = "vikunja-front"
        port = "front"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.tls.certresolver=myresolver",
            "homer.enable=true",
            "homer.name=vikunka",
            "homer.service=Application",
            "homer.logo=https://${NOMAD_JOB_NAME}.ducamps.win/images/icons/apple-touch-icon-180x180.png",
            "homer.target=_blank",
            "homer.url=https://${NOMAD_JOB_NAME}.ducamps.win",
        ]
      }
      config {
        image = "vikunja/frontend"
        ports = ["front"]
      }
      resources {
        memory = 20
      }
    }
    

  }
}
