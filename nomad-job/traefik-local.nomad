job "traefik-local" {
  datacenters = ["homelab"]
  priority    = 90
  type        = "service"

  group "traefik-local" {
    network {
      mode = "host"
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "ssh" {
        static = 2222
      }
      port "smtp" {
        static = 25
      }
      port "esmtp" {
        static = 465
      }
      port "imap" {
        static= 993
      }
      port "admin" {
        static = 9080
      }
    }
    vault {
      policies = ["traefik"]
    }

    task "traefik" {
      driver = "docker"
      service {
        name = "traefik-local"

        tags = ["traefik"]
        port = "https"
      }

      service {
        name = "traefik-local-admin"
        port = "admin"
        tags = [
          "homer.enable=true",
          "homer.name=Traefik admin",
          "homer.subtitle=LAN",
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
          "admin",
          "ssh",
          "smtp",
          "esmtp",
          "imap",
        ]
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "/mnt/diskstation/nomad/traefik/acme-local.json:/acme.json"
        ]

      }
      # vault{
      #}
      env {
      }
      template {
        data        = <<EOH
          HETZNER_API_KEY = "{{with secret "secrets/data/nomad/traefik"}}{{.Data.data.hetznerdnstoken}}{{end}}"
          EOH
        destination = "secrets/gandi.env"
        env         = true
      }

      template {
        data            = <<EOH
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
          [entrypoints.ssh]
            address = ":2222"
          [entrypoints.smtp]
            address = ":25"
          [entrypoints.esmtp]
            address = ":465"
          [entrypoints.imap]
            address = ":993"
        [http.middlewares]
          [http.middlewares.https-redirect.redirectscheme]
            scheme = "https"
        [providers.consulCatalog]
          exposedByDefault = false
          [providers.consulCatalog.endpoint]
            address = "172.17.0.1:8500"
        [log]
        [accessLog]
        [api]
          dashboard = true
          insecure = true
        [ping]
        [certificatesResolvers.myresolver.acme]
        email = "vincent@ducamps.eu"
        storage = "acme.json"
        [certificatesResolvers.myresolver.acme.dnsChallenge]
        provider = "hetzner"
        delayBeforeCheck = 0
        resolvers = ["hydrogen.ns.hetzner.com","oxygen.ns.hetzner.com"]
        [metrics]
          [metrics.prometheus]



        EOH
        destination     = "local/traefik.toml"
        env             = false
        change_mode     = "noop"
        left_delimiter  = "{{{"
        right_delimiter = "}}}"
      }
      resources {
        memory = 200
      }
    }
  }
}
