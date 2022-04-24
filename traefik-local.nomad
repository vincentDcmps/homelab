job "traefik-local" {
  datacenters = ["homelab"]
  type = "service"

  group "traefik-local" {
    network {
      mode = "host"
      port "http" {
        static  = 80
      }
      port "https" {
        static  = 443
      }
      port "admin" {
        static = 9080
      }
    }

     task "server" {
      driver = "docker"
      service {
        name = "traefik-local"

        tags = ["traefik"]
        port = "https"
      }

      service {
        name = "traefi-local-admin"
        port = "admin"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}_insecure.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
        ]
      }

      config {
        image = "traefik"
        ports = [
          "http",
          "https",
          "admin"
        ]
        volumes =[
          "local/traefik.toml:/etc/traefik/traefik.toml"
          #"/mnt/diskstation/nomad/traefik/acme.json:acme.json"
        ]

      }
      # vault{
      #}
    env {
    }
    template{
        data= <<EOH
        [entryPoints]
          [entryPoints.web]
            address = ":80"
          [entryPoints.websecure]
            address = ":443"
          [entryPoints.traefik]
            address = ":9080"
        [http.middlewares]
          [http.middlewares.https-redirect.redirectscheme]
            scheme = "https"
        [providers.consulCatalog]
          exposedByDefault = false
          [providers.consulCatalog.endpoint]
            address = "127.0.0.1:8500"
        [log]
        [api]
          dashboard = true
          insecure = true
        [ping]

        EOH
        destination = "local/traefik.toml"
        env         = false
        change_mode = "noop"
        left_delimiter = "{{{"
        right_delimiter = "}}}"
    }
    }
  }
}
