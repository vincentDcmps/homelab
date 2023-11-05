
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
        static = 8070
        host_network = "private"
      }
      port "torrent" {
        static=6881
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
            "homer.url=https://torrent.ducamps.eu",
            "homer.service=Application",
            "homer.logo=https://cdn.icon-icons.com/icons2/2429/PNG/512/bittorrent_logo_icon_147310.png",
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "linuxserver/qbittorrent"
        ports = [
          "http",
          "torrent"
          ]
        volumes = [
          "/mnt/diskstation/nomad/qbittorent:/config",
          "/mnt/hetzner/storagebox/file:/downloads"
        ]

      }
      env {
        PUID=1024
        PGID=984
        UMASK=002
        TZ="Europe/Paris"
        WEBUI_PORT="8070"
      }

      resources {
        memory = 450
      }
    }

  }
}
