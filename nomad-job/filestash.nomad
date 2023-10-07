
job "filestash" {
  datacenters = ["hetzner"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }


  group "filestash" {
    network {
      mode = "host"
      port "http" {
        to = 8334
      }
      port "onlyoffice" {
        to = 80
      }
    }
    task "filestash" {
      driver = "docker"
      service {
        name = "filestash"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=FileStash",
          "homer.service=Application",
          "homer.url=http://file.ducamps.win",
          "homer.logo=http://file.ducamps.win/assets/logo/apple-touch-icon.png",
          "homer.target=_blank",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`file.ducamps.win`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=file.ducamps.win",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      config {
        image = "machines/filestash"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/filestash:/app/data/state"
        ]

      }
      env {
        APPLICATION_URL = ""
      }

      resources {
        cpu    = 100
        memory = 300
      }
    }

  }
}
