
job "ghostfolio" {
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

  group "main"{
    network {
      mode = "host"
      port "http" {
      }
      port "redis" {
          to = 6379
      }
    }
    vault{

    }
    task "redis" {
        driver = "docker"
        config {
            image = "docker.service.consul:5000/library/redis"
            ports = ["redis"]
        }
        resources {
            memory = 50
        }

    }
    task "server" {
      driver = "docker"
      service {
        name = "${NOMAD_JOB_NAME}"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      config {
        image = "docker.service.consul:5000/ghostfolio/ghostfolio:latest"
        ports = ["http"]
        volumes = [
        ]

      }
      env {
          NODE_ENV = "production"
          REDIS_HOST= "${NOMAD_IP_redis}"
          REDIS_PORT = "${NOMAD_HOST_PORT_redis}"
          PORT = "${NOMAD_PORT_http}"
          JWT_SECRET_KEY = uuidv4()

      }

      template {
        data= <<EOH
          {{ with secret "secrets/data/database/ghostfolio"}}
           DATABASE_URL = postgresql://ghostfolio:{{.Data.data.password}}@active.db.service.consul/ghostfolio?connect_timeout=300&sslmode=prefer
          {{end}}
          {{ with secret "secrets/data/nomad/ghostfolio"}}
          ACCESS_TOKEN_SALT = {{.Data.data.token}}
          {{end}}
          EOH
        destination = "secrets/ghostfolio.env"
        env = true
      }
      resources {
        memory = 400
        memory_max = 600
      }
    }

  }
}
