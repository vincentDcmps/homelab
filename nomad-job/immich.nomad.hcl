job "immich" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "immich" {
    network {
      mode = "host"
      port "http" {
        to = 3001
      }
      port "redis" {
        to = 6379
      }
      port "machinelearning" {
        to = 3003
      }
      port "microservices" {
        to = 3002
      }
    }
    volume "immich-upload" {
      type            = "csi"
      source          = "immich-upload"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    volume "immich-cache" {
      type            = "csi"
      source          = "immich-cache"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    } 
    volume "photo" {
      type            = "csi"
      source          = "photo"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    vault {
      policies = ["immich"]
    }
    task "immich-server" {
      driver = "docker"
      service {
        name = "immich"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=immich",
          "homer.service=Application",
          "homer.logo=https://www.ducamps.eu/tt-rss/images/favicon-72px.png",
          "homer.target=_blank",
          "homer.url=https://immich.ducamps.eu",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
        ]
      }
      volume_mount {
        volume      = "immich-upload"
        destination = "/usr/src/app/upload"
      }
      volume_mount {
        volume      = "photo"
        destination = "/photo"
      }
      config {
        image   = "ghcr.service.consul:5000/immich-app/immich-server:release"
        command = "start.sh"
        args    = ["immich"]
        ports   = ["http"]
        volumes = [
          "/etc/localtime:/etc/localtime"
        ]

      }

      template {
        data        = <<EOH
          {{ with secret "secrets/data/database/immich"}}
          DB_PASSWORD= {{ .Data.data.password }}
          {{end}}
          DB_DATABASE_NAME= immich
          DB_USERNAME= immich
          DB_HOSTNAME= active.db.service.consul
          REDIS_HOSTNAME            = {{env "NOMAD_IP_redis"}}
          REDIS_PORT            = {{env "NOMAD_HOST_PORT_redis"}}
          IMMICH_MACHINE_LEARNING_URL = http://{{ env "NOMAD_ADDR_machinelearning"}}
          EOH
        destination = "secrets/immich.env"
        env         = true
      }
      resources {
        memory = 300
      }
    }
    task "immich-microservce" {
      driver = "docker"

      volume_mount {
        volume      = "immich-upload"
        destination = "/usr/src/app/upload"
      }
      volume_mount {
        volume      = "photo"
        destination = "/photo"
      }
      config {
        image   = "ghcr.service.consul:5000/immich-app/immich-server:release"
        command = "start.sh"
        ports   = ["microservices"]
        args    = ["microservices"]
        volumes = [
          "/etc/localtime:/etc/localtime"
        ]

      }

      template {
        data        = <<EOH
          {{ with secret "secrets/data/database/immich"}}
          DB_PASSWORD= {{ .Data.data.password }}
          {{end}}
          DB_DATABASE_NAME= immich
          DB_USERNAME= immich
          DB_HOSTNAME= active.db.service.consul
          REDIS_HOSTNAME            = {{env "NOMAD_IP_redis"}}
          REDIS_PORT            = {{env "NOMAD_HOST_PORT_redis"}}
          IMMICH_MACHINE_LEARNING_URL = http://{{ env "NOMAD_ADDR_machinelearning"}}
          EOH
        destination = "secrets/immich.env"
        env         = true
      }
      resources {
        memory = 300
      }
    }
    task "immich-machine-learning" {
      driver = "docker"
      volume_mount {
        volume      = "immich-cache"
        destination = "/cache"
      }
      config {
        image = "ghcr.service.consul:5000/immich-app/immich-machine-learning:release"
        ports = ["machinelearning"]
      }

      template {
        data        = <<EOH
          {{ with secret "secrets/data/database/immich"}}
          DB_PASSWORD= {{ .Data.data.password }}
          {{end}}
          DB_DATABASE_NAME= immich
          DB_USERNAME= immich
          DB_HOSTNAME= active.db.service.consul
          REDIS_HOSTNAME            = {{env "NOMAD_IP_redis"}}
          REDIS_PORT            = {{env "NOMAD_HOST_PORT_redis"}}
          EOH
        destination = "secrets/immich.env"
        env         = true
      }
      resources {
        memory = 200
        max_memory = 300
      }
    }

    task "redis" {
      driver = "docker"
      config {
        image="docker.service.consul:5000/library/redis:6.2-alpine"
        ports = ["redis"]
      }
      resources {
        memory = 50
      }
    }
  }
}