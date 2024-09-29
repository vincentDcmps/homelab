job "registry" {
  datacenters = ["homelab"]
  priority    = 100
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "registry" {
    network {
      mode = "host"
      port "docker_registry" {
        to = 5000
      }
      port "ghcr_registry" {
        to = 5000
      }
      port "traefik" {
        to     = 5000
        static = 5000
      }
      port "redis" {
        to = 6379
      }
      port "admin" {
        to = 8080
      }
    }
    volume "registry-docker" {
      type            = "csi"
      source          = "registry-docker"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    volume "registry-ghcr" {
      type            = "csi"
      source          = "registry-ghcr"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    service {
      name = "docker"
      port = "traefik"
    }
    service {
      name = "ghcr"
      port = "traefik"
    }
    task "docker-registry" {
      driver = "docker"
      config {
        image = "registry:2"
        ports = ["docker_registry"]
        volumes = [
          "local/dockerhub.yaml:/etc/docker/registry/config.yml"
        ]

      }
      env {
      }
      volume_mount {
        volume      = "registry-docker"
        destination = "/var/lib/registry"
      }
      template {
        data        = <<EOH
http:
  addr: :5000
log:
  fields:
      service: registry
proxy:
    remoteurl: https://registry-1.docker.io
redis:
  addr:  {{env "NOMAD_ADDR_redis"}}
  db: 0
storage:
  cache:
    blobdescriptor: redis
  filesystem:
    rootdirectory: /var/lib/registry
version: '0.1'

          EOH
        destination = "local/dockerhub.yaml"
      }
      resources {
        memory = 150
        memory_max = 600
      }
    }
    task "docker-ghcr" {
      driver = "docker"
      config {
        image = "registry:2"
        ports = ["ghcr_registry"]
        volumes = [
          "local/ghcr.yaml:/etc/docker/registry/config.yml"
        ]

      }
      env {
      }
      volume_mount {
        volume      = "registry-ghcr"
        destination = "/var/lib/registry"
      }
      template {
        data        = <<EOH
http:
  addr: :5000
log:
  fields:
      service: registry
proxy:
    remoteurl: https://ghcr.io
redis:
  addr: {{env "NOMAD_ADDR_redis"}}
  db: 1
storage:
  cache:
    blobdescriptor: redis
  filesystem:
    rootdirectory: /var/lib/registry
version: '0.1'

          EOH
        destination = "local/ghcr.yaml"
      }
      resources {
        memory = 150
        memory_max = 600
      }
    }

    task "redis" {
      driver = "docker"
      config {
        command = "redis-server"
        args = ["/usr/local/etc/redis/redis.conf"]
        image = "redis"
        ports = ["redis"]
        volumes = [
          "local/redis.conf:/usr/local/etc/redis/redis.conf"
        ]
      }
      template {
        data        = <<EOH
databases 2

          EOH
        destination = "local/redis.conf"
      }
      resources {
        memory = 25
      }
    }

    task "traefik" {
      driver = "docker"
      config {
        image = "traefik"
        ports = ["traefik","admin"]
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml"
        ]

      }

      template {
        data        = <<EOH
[accessLog]
[api]
  dashboard = true
  insecure = true
[entryPoints]
  [entryPoints.docker]
    address = ":5000"
[http]
  [http.routers]
    [http.routers.dockerhub]
      entryPoints = ["docker"]
      rule = "Host(`docker.service.consul`)"
      service = "dockerhub"
      [http.routers.dockerhub.tls]

    [http.routers.ghcr]
      entryPoints = ["docker"]
      rule ="host(`ghcr.service.consul`)"
      service  = "ghcr"
      [http.routers.ghcr.tls]
  [http.services]
    [http.services.dockerhub]
      [[http.services.dockerhub.loadbalancer.servers]]
        url = "http://{{env "NOMAD_ADDR_docker_registry" }}"
    [http.services.ghcr]
      [[http.services.ghcr.loadbalancer.servers]]
        url = "http://{{ env "NOMAD_ADDR_ghcr_registry" }}"
[providers]
[providers.file]
    filename= "/etc/traefik/traefik.toml"

[log]
  level = "DEBUG"
          EOH
        destination = "local/traefik.toml"
      }
      resources {
        memory = 75
      }
    }

  }

}
