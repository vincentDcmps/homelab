job "node-exporter" {
  datacenters = ["homelab", "hetzner"]
  priority    = 30
  type        = "system"
  meta {
    forcedeploy = "0"
  }

  group "node-exporter" {
    network {
      port "http" {
      }
    }
    service {
      name = "node-exporter"
      port = "http"
      check {
        type                     = "http"
        port                     = "http"
        path                     = "/"
        interval                 = "10s"
        timeout                  = "2s"
        success_before_passing   = "3"
        failures_before_critical = "3"
        check_restart {
          limit = 3
          grace = "60s"
        }
      }
    }

    task "node-exporter" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/prom/node-exporter"
        ports = ["http"]
        args = [
          "--web.listen-address=:${NOMAD_PORT_http}",
          "--path.procfs=/host/proc",
          "--path.sysfs=/host/sys",
          "--collector.filesystem.ignored-mount-points",
          "^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)"

        ]

        mount {
          type     = "bind"
          target   = "/host/proc"
          source   = "/proc"
          readonly = true
        }

        mount {
          type     = "bind"
          target   = "/host/sys"
          source   = "/sys"
          readonly = true
        }

      }

      resources {
        cpu    = 20
        memory = 30
      }
    }

  }
}
