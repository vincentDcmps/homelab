
job "deconz" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }
   constraint {
     attribute = "${attr.unique.hostname}"
     value     = "oscar"
  }

    group "deconz"{
    network {
      mode = "host"
      port "http" {
        to = 8124
        static = 8124
      }
      port "ws" {}
    }

    task "deconz" {
      driver = "docker"
      service {
        name = "deconz"
        port = "http"
        tags = [
            "homer.enable=true",
            "homer.name=Deconz",
            "homer.service=Application",
            "homer.logo=https://tutoriels.domotique-store.fr/images/JeeBox/plugin-zigbee/icone-plugin-zigbee-officiel-jeedom.png?1632754975124",
            "homer.target=_blank",
            "homer.url=http://${NOMAD_ADDR_http}",

 
        ]
      }
      config {
        image = "deconzcommunity/deconz"
        ports = ["http","ws"]
        privileged = true
        volumes = [
          "/mnt/diskstation/nomad/deconz:/opt/deCONZ",
          "/dev/ttyACM0:/dev/ttyACM0"
        ]

      }
      env {
         DECONZ_DEVICE = "/dev/ttyACM0"
         TZ = "Europe/Paris"
         DECONZ_WEB_PORT = "${NOMAD_PORT_http}"
         DECONZ_WS_PORT = "${NOMAD_PORT_ws}"
      }
      resources {
        memory = 150
      }

    }

  }
}
