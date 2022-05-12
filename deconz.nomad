
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
        ]
      }
      config {
        image = "deconzcommunity/deconz"
        ports = ["http"]
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
        memory = 75
      }

    }

  }
}
