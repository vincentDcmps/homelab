
job "jellyfin" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  group "jellyfin"{
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
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "jellyfin/jellyfin"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/jellyfin/config:/config",
          "/mnt/diskstation/media/:/media"
        ]

      }
      resources {
        memory = 900
        cpu= 3000
      }
    }

  }
}
