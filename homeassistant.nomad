
job "homeassistant" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "1"
  }
  constraint {
     attribute = "${attr.unique.hostname}"
     value     = "oscar"
  }

  group "homeassistant"{
    network {
      mode = "host"
      port "http" {
        to = 8123
        static = 8123
      }
      port "coap"{
        to = 5683
        static = 5683
      }
    }
    vault{
      policies= ["access-tables"]

    }



    task "hass" {
      driver = "docker"
      service {
        name = "${NOMAD_TASK_NAME}"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.middlewares.httpsRedirect.redirectscheme.scheme=https",
            "traefik.http.routers.${NOMAD_TASK_NAME}_insecure.middlewares=httpsRedirect",
            "traefik.http.routers.${NOMAD_TASK_NAME}_insecure.rule=Host(`${NOMAD_TASK_NAME}.ducamps.win`)"
            "traefik.http.routers.${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_TASK_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_TASK_NAME}.tls.domains[0].sans=${NOMAD_TASK_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_TASK_NAME}.tls.certresolver=myresolver",
        ]
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      config {
        image = "homeassistant/home-assistant:stable"
        ports = ["http","coap"]
        privileged = "true"
        network_mode = "host"
        volumes = [
          "/mnt/diskstation/nomad/hass:/config",
        ]
      }
      env {
        TZ = "Europe/Paris"
      }
      resources {
        cpu    = 800 # 500 MHz
        memory = 512 # 512 MB
    }
    }
  }

  }
