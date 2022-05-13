
job "alertmanager" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }

  group "alertmanager"{
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
        tags = ["urlprefix-/alertmanager strip=/alertmanager"]
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
