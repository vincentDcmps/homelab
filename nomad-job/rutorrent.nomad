
job "torrent" {
  datacenters = ["hetzner"]
  priority    = 80
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  group "bittorent" {
    network {
      mode = "host"
      port "http" {
        to           = 8080
        host_network = "private"
      }
      port "torrent" {
        static       = 6881
        host_network = "public"
      }
      port "ecoute" {
        static       = 50000
        host_network = "public"
      }
    }
    task "bittorent" {
      driver = "podman"
      service {
        name = "bittorent"
        port = "http"
        address_mode= "host"
        tags = [
          "homer.enable=true",
          "homer.name=torrent",
          "homer.url=https://torrent.ducamps.eu",
          "homer.service=Application",
          "homer.logo=https://fleet.linuxserver.io/images/linuxserver_rutorrent.png",
          "homer.target=_blank",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
          "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=authelia-basic",
        ]
      }
      user = "root"
      config {
        
        image = "docker.service.consul:5000/crazymax/rtorrent-rutorrent:edge"
        privileged = "true"
        ports = [
          "http",
          "torrent",
          "ecoute"
        ]
        volumes = [
          "/opt/rutorrentConfig:/data",
          "/mnt/hetzner/storagebox/file:/downloads"
        ]

      }
      env {
        PUID       = 1000001
        PGID       = 10
        UMASK      = 002
        WEBUI_PORT = "8080"
      }

      resources {
        memory = 450
      }
    }

  }
}
