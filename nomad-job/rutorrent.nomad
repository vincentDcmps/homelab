
job "torrent" {
  datacenters = ["hetzner"]
  priority    = 80
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  vault {
    policies= ["torrent"]
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
          "homer.logo=https://${NOMAD_JOB_NAME}.ducamps.eu/images/favicon-196x196.png",
          "homer.target=_blank",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
          "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=torrentauth",
          "traefik.http.middlewares.torrentauth.basicauth.users=admin:${ADMIN_HASHED_PWD}"
        ]
      }
      template {
        data = <<-EOF
          ADMIN_HASHED_PWD={{ with secret "secrets/nomad/torrent" }}{{.Data.data.hashed_pwd}}{{ end }}
        EOF
        destination = "secrets/env"
        env = true
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
          "/mnt/hetzner/storagebox/rutorrentConfig:/data",
          "/mnt/hetzner/storagebox/file:/downloads"
        ]

      }
      env {
        PUID       = 100001
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
