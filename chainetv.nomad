
job "chainetv" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "2"
  }
  group "chainetv"{
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
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`www.ducamps.win`)&&PathPrefix(`/chainetv`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=www.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=chainetv,chainetvStrip",
            "traefik.http.middlewares.chainetv.headers.customrequestheaders.X-Script-Name=/chainetv",
            "traefik.http.middlewares.chainetvStrip.stripprefix.prefixes=/chainetv",

        ]
      }
      config {
        image = "ducampsv/chainetv:latest"
        ports = ["http"]
      }
      resources {
        memory = 200
      }
    }
  }

}
