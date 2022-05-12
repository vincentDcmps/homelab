
job "radicale" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }
  group "radicale"{
    network {
      mode = "host"
      port "http" {
        to = 5232
      }
    }
    vault{
      policies= ["acces-policy"]

    }
    task "radicale" {
      driver = "docker"
      service {
        name = "radicale"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`rss.ducamps.win`)&&PathPrefix(`/radicale`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=rss.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=radicaleHeader,radicalestrip",
            "traefik.http.middlewares.radicaleHeader.headers.customrequestheaders.X-Script-Name=/radicale",
            "traefik.http.middlewares.radicalestrip.stripprefix.prefixes=/radicale",

        ]
      }
      config {
        image = "tomsquest/docker-radicale"
        ports = ["http"]
        volumes = [
          "local/config:/config/config",
          "/mnt/diskstation/CardDav:/data"
        ]

      }
      env {
        TAKE_FILE_OWNERSHIP=false
      }
      template {
        data = <<EOH
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
