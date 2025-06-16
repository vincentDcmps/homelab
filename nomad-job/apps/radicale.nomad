
job "radicale" {
  datacenters = ["homelab"]
  priority    = 70
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  group "radicale" {
    network {
      mode = "host"
      port "http" {
        to = 5232
      }
    }
    task "radicale" {
      driver = "docker"
      service {
        name = "radicale"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=Radicale",
          "homer.service=Application",
          "homer.logo=https://radicale.org/assets/logo.svg",
          "homer.target=_blank",
          "homer.url=https://www.ducamps.eu/${NOMAD_JOB_NAME}",


          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`www.ducamps.eu`)&&PathPrefix(`/radicale`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=www.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=radicaleHeader,radicalestrip",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
          "traefik.http.middlewares.radicaleHeader.headers.customrequestheaders.X-Script-Name=/radicale",
          "traefik.http.middlewares.radicalestrip.stripprefix.prefixes=/radicale",

        ]
      }
      config {
        image = "docker.service.consul:5000/tomsquest/docker-radicale:3.5.4.0"
        ports = ["http"]
        volumes = [
          "local/config:/config/config",
          "/mnt/diskstation/nomad/radicale:/data"
        ]

      }
      env {
        TAKE_FILE_OWNERSHIP = false
      }
      template {
        data        = <<EOH
          [server]
          hosts = 0.0.0.0:5232
          [auth]
          type = htpasswd
          htpasswd_encryption = md5
          htpasswd_filename = /data/users.htpasswd
          delay = 1
          [rights]
          type = from_file
          file = /data/rights.conf
          [storage]
          type = multifilesystem
          filesystem_folder = /data/collections
          EOH
        destination = "local/config"
      }
      resources {
        memory = 100
      }
    }

  }
}
