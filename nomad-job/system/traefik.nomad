job "traefik" {
  datacenters = ["hetzner"]
  priority    = 90
  type        = "service"

  meta {
    force_deploy = 1
  }
  group "traefik" {
    network {
      mode = "host"
      port "http" {
        static       = 80
        host_network = "public"
      }
      port "https" {
        static       = 443
        host_network = "public"
      }
      port "admin" {
        static       = 9080
        host_network = "private"
      }
      port "ssh" {
        static       = 2222
        host_network = "public"
      }
      port "smtp" {
        static = 25
        host_network = "public"
      }
      port "esmtp" {
        static = 465
        host_network = "public"
      }
      port "imap" {
        static= 993
        host_network = "public"
      }
    }
    vault {
      policies = ["traefik"]
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
        image = "docker.service.consul:5000/library/traefik:v3.4"
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
          "/mnt/diskstation/nomad/traefik/acme.json:/acme.json"
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

          [entrypoints.ssh]
            address = ":2222"
          [entryPoints.web]
            address = ":80"
            [entryPoints.web.http]
              [entryPoints.web.http.redirections]
                [entryPoints.web.http.redirections.entryPoint]
                  to = "websecure"
                  scheme = "https"

          [entryPoints.websecure]

            address = ":443"
            [entryPoints.websecure.forwardedHeaders]
              trustedIPs = ["127.0.0.1/32", "192.168.0.0/24" ,"10.0.0.0/8","172.16.0.0/12"]
            [entryPoints.websecure.proxyProtocol] 
              trustedIPs = ["127.0.0.1/32", "192.168.0.0/24" ,"10.0.0.0/8","172.16.0.0/12"]
          [entryPoints.traefik]
            address = ":9080"
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
            address = "{{{env "NOMAD_IP_admin"}}}:8500"
        [log]
        [accessLog]
        [api]
          dashboard = true
          insecure = true
        [ping]
        [certificatesResolvers.myresolver.acme]
        email = "vincent@ducamps.eu"
        storage = "acme.json"
        [certificatesResolvers.myresolver.acme.httpChallenge]
        entryPoint= "web"
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
