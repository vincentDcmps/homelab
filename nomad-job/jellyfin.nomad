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
  group jellyfin-vue {
    network {
      mode = "host"
      port "http" {
        to = 80
      }
    }
    task "jellyfin-vue" {
      driver = "docker"
      service {
        name = "jellyfin-vue"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=${NOMAD_TASK_NAME}",
          "homer.service=Application",
          "homer.target=_blank",
          "homer.logo=https://${NOMAD_TASK_NAME}.ducamps.eu/icon.png",
          "homer.url=https://${NOMAD_TASK_NAME}.ducamps.eu",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_TASK_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_TASK_NAME}.tls.domains[0].sans=${NOMAD_TASK_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_TASK_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_TASK_NAME}.entrypoints=web,websecure",
        ]

      }
      config {
        image = "ghcr.io/jellyfin/jellyfin-vue:unstable"
        ports = ["http"]
      }
      env {
        DEFAULT_SERVERS = "${NOMAD_TASK_NAME}.ducamps.eu"
      }

      resources {

        memory = 50
        cpu    = 100
      }

    }
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
          "homer.logo=https://${NOMAD_JOB_NAME}.ducamps.eu/web/assets/img/banner-light.png",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      config {
        image = "jellyfin/jellyfin"
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
