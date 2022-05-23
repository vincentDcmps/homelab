
job "syncthing" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }

  group "syncthing"{
    network {
      mode = "host"
      port "http" {
        to = 8384
      }
      port "listen"{
        static = 22000
      }
      port "discovery" {
        static = 21027
      }
    }
    vault{
      policies= ["policy_name"]

    }
    task "syncthing" {
      driver = "docker"
      service {
        name = "syncthing-web"
        port = "http"
      }
      config {
        image = "linuxserver/syncthing"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/syncthing/config:/config",
          "/mnt/diskstation/nomad/syncthing/data:/data1"
        ]

      }
      resources {
        memory = 200
      }
    }

  }
}
