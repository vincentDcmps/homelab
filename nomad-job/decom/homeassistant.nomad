
job "homeassistant" {
  datacenters = ["homelab"]
  priority    = 90
  type        = "service"
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "homeassistant" {
    network {
      mode = "host"
      port "http" {
        to     = 8123
        static = 8123
      }
      port "coap" {
        to     = 5683
        static = 5683
      }
    }



    task "hass" {
      driver = "docker"
      service {
        name = "${NOMAD_TASK_NAME}"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=Hass",
          "homer.service=Application",
          "homer.subtitle=Home Assistant",
          "homer.logo=https://raw.githubusercontent.com/home-assistant/assets/master/logo/logo-small.svg",
          "homer.target=_blank",
          "homer.url=https://${NOMAD_TASK_NAME}.ducamps.eu",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_TASK_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_TASK_NAME}.tls.domains[0].sans=${NOMAD_TASK_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_TASK_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_TASK_NAME}.entrypoints=web,websecure",
        ]
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      config {
        image        = "docker.service.consul:5000/homeassistant/home-assistant:stable"
        ports        = ["http", "coap"]
        privileged   = "true"
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
        max_memory = 2000
      }
    }
  }

}
