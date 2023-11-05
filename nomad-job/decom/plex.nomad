
job "plex" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  group "plex"{
    network {
      mode = "host"
      port "http" {
         static = 32400
      }
    }

    task "plex" {
      driver = "docker"
      service {
        name = "plex"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "plexinc/pms-docker"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/plex/config:/config",
          "/mnt/diskstation/media/:/data"
        ]

      }
      resources {
        memory = 300
      }
    }

  }
}
