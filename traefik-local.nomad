job "traefik-local" {
  datacenters = ["homelab"]
  type = "service"
  constraint {
     attribute = "${attr.unique.hostname}"
     value     = "gerard"
  }
  group "traefik-local" {
    network {
      mode = "host"
      port "http" {
        static  = 80
      }
      port "https" {
        static  = 443
      }
      port "ssh" {
        static = 2222
      }
     port "admin" {
        static = 9080
      }
    }
   vault{
      policies=["access-tables"]
    }

     task "traefik-local" {
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
          "admin",
          "ssh"
        ]
        volumes =[
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "/mnt/diskstation/nomad/traefik/acme-local.json:/acme.json"
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
          [entryPoints.websecure]
            address = ":443"
          [entryPoints.traefik]
            address = ":9080"
          [entrypoints.ssh]
            address = ":2222"
        [http.middlewares]
          [http.middlewares.https-redirect.redirectscheme]
            scheme = "https"
        [providers.consulCatalog]
          exposedByDefault = false
          [providers.consulCatalog.endpoint]
            address = "172.17.0.1:8500"
        [log]
        [api]
          dashboard = true
          insecure = true
        [ping]
        [certificatesResolvers.myresolver.acme]
        email = "vincent@ducamps.win"
        storage = "acme.json"
        [certificatesResolvers.myresolver.acme.dnsChallenge]
        provider = "gandiv5"
        delayBeforeCheck = 0
        resolvers = ["173.246.100.133:53"]


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
