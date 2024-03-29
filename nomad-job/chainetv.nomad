
job "chainetv" {
  datacenters = ["homelab"]
  priority = 30
  type        = "service"
  meta {
    forcedeploy = "2"
  }
  group "chainetv" {
    network {
      mode = "host"
      port "http" {
        to = 5000
      }
    }

    task "chainetv" {
      driver = "docker"
      service {
        name = "chainetv"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=ChaineTV",
          "homer.service=Application",
          "homer.icon=fas fa-tv",
          "homer.target=_blank",
          "homer.url=https://www.ducamps.eu/${NOMAD_JOB_NAME}",

          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`www.ducamps.eu`)&&PathPrefix(`/chainetv`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=www.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
          "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=chainetv,chainetvStrip",
          "traefik.http.middlewares.chainetv.headers.customrequestheaders.X-Script-Name=/chainetv",
          "traefik.http.middlewares.chainetvStrip.stripprefix.prefixes=/chainetv",

        ]
      }
      config {
        image = "docker.service.consul:5000/ducampsv/chainetv:latest"
        ports = ["http"]
      }
      resources {
        memory = 200
      }
    }
  }

}
