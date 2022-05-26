job "traefik-ingress" {
  datacenters = ["hetzner"]
  type = "service"

  meta {
    force_deploy= 1
  }
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
    vault{
      policies=["access-tables"]
    }
     task "traefik" {
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
            "homer.enable=true",
            "homer.name=Traefik admin",
            "homer.subtitle=WAN",
            "homer.service=Platform",
            "homer.logo=https://upload.wikimedia.org/wikipedia/commons/1/1b/Traefik.logo.png",
            "homer.target=_blank",
            "homer.url=http://${NOMAD_ADDR_admin}",


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
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "/mnt/diskstation/nomad/traefik/acme.json:/acme.json"
        ]

      }
      # vault{
      #}
    env {
    }
    template{
      data=<<EOH
        GANDIV5_API_KEY = "{{with secret "secrets/data/gandi"}}{{.Data.data.API_KEY}}{{end}}"
        EOH
      destination= "secrets/gandi.env"
      env = true
    }
    template{
        data= <<EOH
        [entryPoints]
          [entryPoints.web]
            address = ":80"
            [entryPoints.web.http]
              [entryPoints.web.http.redirections]
                [entryPoints.web.http.redirections.entryPoint]
                  to = "websecure"
                  scheme = "https"
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
        [accessLog]
        [api]
          dashboard = true
          insecure = true
        [ping]
        [certificatesResolvers.myresolver.acme]
        email = "vincent@ducamps.win"
        storage = "acme.json"
        [certificatesResolvers.myresolver.acme.httpChallenge]
        entryPoint= "web"
        [metrics]
          [metrics.prometheus]


        EOH
        destination = "local/traefik.toml"
        env         = false
        change_mode = "noop"
        left_delimiter = "{{{"
        right_delimiter = "}}}"
    }
    resources {
      memory = 200
    }
    }
  }
}
