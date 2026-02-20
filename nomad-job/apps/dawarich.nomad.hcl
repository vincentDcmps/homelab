job "dawarich" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  group "dawarich"{
    network {
     port "http" {
        to = 3000
      }

     port "redis" {
        to = 6379
      }

    }
    volume "dawarich-data" {
      type            = "csi"
      source          = "dawarich-data"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    vault{
    }
    
    task "redis" {
      driver = "docker"
      config {
        image="docker.service.consul:5000/library/redis:8.6-alpine"
        ports = ["redis"]
      }
      resources {
        memory = 50
      }
    }

    task "server" {
      driver = "docker"
      service {
        name = "dawarich"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`geo.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=geo.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      volume_mount {
        volume      = "dawarich-data"
        destination = "/data"
      }
      config {
        image = "docker.service.consul:5000/freikin/dawarich:1.2.0"
        ports = ["http"]
        entrypoint = ["web-entrypoint.sh"]
        command = "bin/rails"
        args= ["server", "-p", "3000", "-b", "::"]

        volumes = [
          "data/public:/var/app/public",
          "data/tmp/imports/watched:/var/app/tmp/imports/watched",
          "data/storage:/var/app/storage",
        ]
      }
      env {
        RAILS_ENV = "production"
        DATABASE_HOST = "active.db.service.consul"
        DATABASE_PORT = 5432
        DATABASE_USERNAME = "dawarich"
        DATABASE_NAME = "dawarich"
        MIN_MINUTES_SPENT_IN_CITY = 60
        APPLICATION_HOSTS = "localhost, = =1,127.0.0.1,geo.ducamps.eu,192.168.1.40,192.168.1.41,192.168.1.42"
        TIME_ZONE = "Europe/Paris"
        APPLICATION_PROTOCOL = "http"
        PROMETHEUS_EXPORTER_ENABLED = false
        PROMETHEUS_EXPORTER_HOST = "0.0.0.0"
        PROMETHEUS_EXPORTER_PORT = 9394
        RAILS_LOG_TO_STDOUT = "true"
        STORE_GEODATA = "true"
      }

      template {
        data= <<EOH
          REDIS_URL = redis://{{env "NOMAD_IP_redis"}}:{{env "NOMAD_HOST_PORT_redis"}}

          SECRET_KEY_BASE = "1234567890"
          {{ with secret "secrets/data/database/dawarich"}}
             DATABASE_PASSWORD = {{ .Data.data.password }}
          {{end}}
        EOH
        destination = "secrets/dawarich.env"
        env = true
      }
      resources {
        memory = 400
      }
    }
    task "sidekiq" {
      driver = "docker"
      volume_mount {
        volume      = "dawarich-data"
        destination = "/data"
      }
      config {
        image = "docker.service.consul:5000/freikin/dawarich:1.2.0"
        entrypoint = ["sidekiq-entrypoint.sh"]
        volumes = [
          "data/public:/var/app/public",
          "data/tmp/imports/watched:/var/app/tmp/imports/watched",
          "data/storage:/var/app/storage",
        ]
      }
      env {
        RAILS_ENV = "production"
        DATABASE_HOST = "active.db.service.consul"
        DATABASE_PORT = 5432
        DATABASE_USERNAME = "dawarich"
        DATABASE_NAME = "dawarich"
        APPLICATION_HOSTS = "localhost, = =1,127.0.0.1,geo.ducamps.eu,192.168.1.40,192.168.1.41,192.168.1.42"
        APPLICATION_PROTOCOL = "http"
        BACKGROUND_PROCESSING_CONCURRENCY= 10
        PROMETHEUS_EXPORTER_ENABLED = false
        PROMETHEUS_EXPORTER_HOST = "0.0.0.0"
        PROMETHEUS_EXPORTER_PORT = 9394
        RAILS_LOG_TO_STDOUT = "true"
        STORE_GEODATA = "true"
      }

      template {
        data= <<EOH
          REDIS_URL = redis://{{env "NOMAD_IP_redis"}}:{{env "NOMAD_HOST_PORT_redis"}}

          SECRET_KEY_BASE = "1234567890"
          {{ with secret "secrets/data/database/dawarich"}}
             DATABASE_PASSWORD = {{ .Data.data.password }}
          {{end}}
        EOH
        destination = "secrets/dawarich.env"
        env = true
      }
      resources {
        memory = 300
      }
    }

  }
}
