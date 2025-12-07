job "jellyfin" {
  datacenters = ["homelab"]
  priority    = 30
  type        = "service"

  meta {
    forcedeploy = "1"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  group "jellyfin" {
    network {
      mode = "host"
      port "http" {
        to = 8096
      }
    }

    task "jellyfin" {
      driver = "docker"
      service {
        name = "jellyfin"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=jellyfin",
          "homer.service=Application",
          "homer.target=_blank",
          "homer.logo=https://jellyfin.ducamps.eu/web/favicons/touchicon144.png",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      config {
        image = "docker.service.consul:5000/jellyfin/jellyfin:10.11"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/jellyfin/config:/config",
          "/mnt/diskstation/nomad/jellyfin/cache:/cache",
          "/mnt/diskstation/media:/media",
          "/mnt/diskstation/music:/music",
        ]
        devices = [
          {
            host_path      = "/dev/dri/renderD128"
            container_path = "/dev/dri/renderD128"
          },
          {
            host_path      = "/dev/dri/card0"
            container_path = "/dev/dri/card0"
          }
        ]

      }
      resources {
        memory     = 2000
        memory_max = 4000
        cpu        = 3000
      }
    }

  }
}
