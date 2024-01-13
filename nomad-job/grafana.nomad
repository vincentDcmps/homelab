job "grafana" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploiement = 2
  }
  group "grafana" {
    network {
      port "http" {
        to = 3000
      }
    }
    volume "grafana" {
      type = "csi"
      source = "grafana"
      access_mode = "multi-node-multi-writer"
      attachment_mode = "file-system"
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
      volume_mount {
        volume = "grafana"
        destination = "/grafana"
      }
      driver = "docker"
      config {
        image = "grafana/grafana"
        ports = ["http"]
        volumes = [
          "grafana:/etc/grafana",
          "grafana:/var/lib/grafana"
        ]
      }
      resources {
        memory = 250
      }
    }
  }
}
