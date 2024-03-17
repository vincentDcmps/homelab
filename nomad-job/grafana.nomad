job "grafana" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  meta {
    forcedeploiement = 2
  }
  group "grafana" {
    network {
      port "http" {
        to = 3000
      }
    }
    service {
      name = "grafana"
      port = "http"
      tags = [
        "homer.enable=true",
        "homer.name=Grafana",
        "homer.service=Monitoring",
        "homer.logo=https://grafana.ducamps.eu/public/img/grafana_icon.svg",
        "homer.target=_blank",
        "homer.url=https://${NOMAD_JOB_NAME}.ducamps.eu",

        "traefik.enable=true",
        "traefik.http.routers.grafana.entryPoints=websecure",
        "traefik.http.routers.grafana.rule=Host(`grafana.ducamps.eu`)",
        "traefik.http.routers.grafana.tls.domains[0].sans=grafana.ducamps.eu",
        "traefik.http.routers.grafana.tls.certresolver=myresolver",
        "traefik.http.routers.grafana.entrypoints=web,websecure",

      ]
    }

    task "dashboard" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/grafana/grafana"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/grafana/config:/etc/grafana",
          "/mnt/diskstation/nomad/grafana/lib:/var/lib/grafana"
        ]
      }
      resources {
        memory = 250
      }
    }
  }
}
