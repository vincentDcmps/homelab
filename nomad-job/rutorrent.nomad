
job "torrent" {
  datacenters = ["hetzner"]
  type = "service"
  meta {
    forcedeploy = "0"
  }
  group "bittorent"{
    network {
      mode = "host"
      port "http" {
        to = 8080
        host_network = "private"
      }
      port "torrent" {
        static=6881
        host_network = "public"
      }
      port "ecoute" {
        static= 50000
        host_network = "public"
      }
    }
    task "bittorent" {
      driver = "docker"
      service {
        name = "bittorent"
        port = "http"
        tags = [
            "homer.enable=true",
            "homer.name=torrent",
            "homer.url=https://torrent.ducamps.win",
            "homer.service=Application",
            "homer.logo=https://${NOMAD_JOB_NAME}.ducamps.win/images/favicon-196x196.png",
            "homer.target=_blank",
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "crazymax/rtorrent-rutorrent"
        ports = [
          "http",
          "torrent",
          "ecoute"
          ]
        volumes = [
          "/mnt/hetzner/rutorrentConfig:/data",
          "/mnt/hetzner/storagebox/file:/downloads"
        ]

      }
      env {
        PUID=1024
        PGID=984
        UMASK=002
        WEBUI_PORT="8070"
      }

      resources {
        memory = 450
      }
    }

  }
}