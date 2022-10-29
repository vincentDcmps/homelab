
job "alertmanager" {
  datacenters = ["homelab"]
  type        = "service"
  meta {
    forcedeploy = "0"
  }

  group "alertmanager" {
    network {
      mode = "host"
      port "http" {
        static = 9093
      }
    }
    task "alertmanager" {
      driver = "docker"
      service {
        name = "alertmanager"
        port = "http"
        tags = [
          "urlprefix-/alertmanager strip=/alertmanager",
          "homer.enable=true",
          "homer.name=AlertManager",
          "homer.service=Monitoring",
          "homer.logo=https://camo.githubusercontent.com/13ff7fc7ea6d8a6d98d856da8e3220501b9e6a89620f017d1db039007138e062/687474703a2f2f6465766f70792e696f2f77702d636f6e74656e742f75706c6f6164732f323031392f30322f7a616c2d3230302e706e67",
          "homer.target=_blank",
          "homer.url=http://${NOMAD_ADDR_http}",

        ]
        check {
          name     = "alertmanager_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image = "prom/alertmanager"
        ports = ["http"]

      }
      resources {
        memory = 75
      }
    }
  }
}
