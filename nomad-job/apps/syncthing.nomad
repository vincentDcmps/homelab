
job "syncthing" {
  datacenters = ["homelab"]
  priority    = 70
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }

  group "syncthing" {
    network {
      mode = "host"
      port "http" {
        to = 8384
      }
      port "listen" {
        static = 22000
      }
      port "discovery" {
        static = 21027
      }
    }
    task "syncthing" {
      driver = "docker"
      service {
        name = "syncthing-web"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=Syncthing",
          "homer.service=Application",
          "homer.logo=http://${NOMAD_ADDR_http}/assets/img/logo-horizontal.svg",
          "homer.target=_blank",
          "homer.url=http://${NOMAD_ADDR_http}",
        ]
      }
      config {
        image = "docker.service.consul:5000/linuxserver/syncthing:1.29.7"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/syncthing/config:/config",
          "/mnt/diskstation/nomad/syncthing/data:/data1"
        ]

      }

      env{
        PUID = 1000001
        GUID = 1000001
      }
      resources {
        memory = 200
      }
    }

  }
}
