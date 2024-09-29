
job "rutorrentlocal" {
  datacenters = ["homelab"]
  priority    = 80
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${node.unique.name}"
    operator = "set_contains"
    value = "oberon"
  }
  group "bittorent" {
    network {
      mode = "host"
      port "http" {
        to           = 8080
      }
      port "torrent" {
        static       = 6881
      }
      port "ecoute" {
        static       = 50000
      }
    }
    task "bittorent" {
      driver = "podman"
      service {
        name = "bittorentlocal"
        port = "http"
        address_mode= "host"
        tags = [
        ]
      }
      user = "root"
      config {
        
        image = "docker.service.consul:5000/crazymax/rtorrent-rutorrent:edge"
        ports = [
          "http",
          "torrent",
          "ecoute"
        ]
        volumes = [
          "/exports/nomad/rutorrent/data:/data",
          "/exports/nomad/rutorrent/downloads:/downloads"
        ]

      }
      env {
        PUID       = 100001
        PGID       = 10
        UMASK      = 002
        WEBUI_PORT = "8080"
      }

      resources {
        memory = 650
      }
    }

  }
}
