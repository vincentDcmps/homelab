job "torrent_automation" {
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
  constraint {
        attribute = "${node.class}"
            operator = "set_contains"
                value = "cluster"
                  }
  group "prowlarr"{
    network {
      mode = "host"
      port "prowlarr" {
        static = 9696
        to = 9696
      }
      port "flaresolverr" {
        static = 8191
        to = 8191
      }

    }
    task "flaresolverr" {
     driver = "docker"
      service {
        name = "flaresolverr"
        port = "flaresolverr"
        
      }
      config {
        image = "ghcr.io/flaresolverr/flaresolverr:latest"
        ports = ["flaresolverr"]
      }
      env {
      }

      resources {
        memory = 300
        memory_max = 500
      }


    }
    task "prowlarr" {
      driver = "docker"
      service {
        name = "prowlarr"
        port = "prowlarr"
        tags = [
          "homer.enable=true",
          "homer.name=Prowlarr",
          "homer.service=Application",
          "homer.logo=http://${NOMAD_ADDR_prowlarr}/Content/Images/logo.png",
          "homer.target=_blank",
          "homer.url=http://${NOMAD_ADDR_prowlarr}",

        ]
        
      }
      config {
        image = "ghcr.io/linuxserver/prowlarr:latest"
        ports = ["prowlarr"]
        volumes = [
          "/mnt/diskstation/nomad/prowlarr:/config"
        ]

      }
      env {
        PUID=1000001
        PGID=1000001
        TZ="Europe/Paris"
      }

      resources {
        memory = 150
      }
    }

  }
}
