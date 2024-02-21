
job "filestash" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploy = "0"
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
          "homer.url=http://file.ducamps.eu",
          "homer.logo=http://file.ducamps.eu/assets/logo/apple-touch-icon.png",
          "homer.target=_blank",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`file.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=file.ducamps.eu",
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
