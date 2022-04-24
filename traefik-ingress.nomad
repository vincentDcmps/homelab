job "traefik-ingress" {
  datacenters = ["hetzner"]
  type = "service"

  group "traefik-ingress" {
    network {
      mode = "host"
      port "http" {
        static  = 80
        host_network = "public"
      }
      port "https" {
        static  = 443
        host_network = "public"
      }
      port "admin" {
        static = 9080
        host_network = "private"
      }
    }

     task "server" {
      driver = "docker"
      service {
        name = "traefik"

        tags = ["traefik"]
        port = "https"
      }

      service {
        name = "traefik-admin"
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
            address = "10.0.0.1:8500"
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
