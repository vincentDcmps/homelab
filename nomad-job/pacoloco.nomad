
job "pacoloco" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  group "pacoloco" {
    network {
      mode = "host"
      port "http" {
        to = 9129
      }
    }
    task "pacoloco-server" {
      driver = "docker"
      service {
        name = "pacoloco"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`arch.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=arch.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
        ]
      }
      config {
        image = "docker.service.consul:5000/ducampsv/pacoloco"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/pacoloco:/var/cache/pacoloco",
          "local/pacoloco.yaml:/etc/pacoloco.yaml"
        ]

      }

      template {
        data        = <<EOH
port: 9129
cache_dir: /var/cache/pacoloco
purge_files_after: 360000
download_timeout: 3600
repos:
  archlinux_x86_64:
    urls:
      - http://archlinux.mailtunnel.eu
      - http://mirror.cyberbits.eu/archlinux
      - http://mirrors.niyawe.de/archlinux
  archlinux_armv8:
    url: http://mirror.archlinuxarm.org
  archlinux_armv7h:
    url: http://mirror.archlinuxarm.org
prefetch:
  cron: 0 0 3 * * * *
  ttl_unaccessed_in_days: 30
  ttl_unupdated_in_days: 300
    EOH
        destination = "local/pacoloco.yaml"
      }
      resources {
        memory = 200
      }
    }

  }
}
