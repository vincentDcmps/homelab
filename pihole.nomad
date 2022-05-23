
job "pihole" {
  datacenters = ["homelab"]
  type = "service"
     constraint {
     attribute = "${attr.unique.hostname}"
     value     = "oscar"
  }
   group "pi-hole" {
    network {
      mode = "host"
      port "dns" {
        static       = 53
      }
      port "http" {
        static       = 8090
        to           = 80
      }
    }
    service {
        name = "pihole-gui"
        tags = ["pihole", "admin",
            "homer.enable=true",
            "homer.name=Pi-hole",
            "homer.service=Application",
            "homer.type=PiHole",
            "homer.logo=http://${NOMAD_ADDR_http}/admin/img/logo.svg",
            "homer.target=_blank",
            "homer.url=http://${NOMAD_ADDR_http}/admin",

        ]
        port = "http"
    }
    task "server" {
      driver = "docker"
      config {
        image = "pihole/pihole:latest"
        ports = [
          "dns",
          "http",
        ]
        volumes =[
        "local/dnsmasq.d/02-localresolver.conf:/etc/dnsmasq.d/02-localresolver.conf",
        "/mnt/diskstation/nomad/pihole:/etc/pihole"
        ]

      }
    vault{
      policies= ["access-tables"]

    }
    env {
      TZ= "Europe/Paris"
      DNS1= "1.1.1.1"
      DNS2= "80.67.169.40"

    }
    template {
      data = <<EOH
        WEBPASSWORD="{{with secret "secrets/data/pihole"}}{{.Data.data.WEBPASSWORD}}{{end}}"
        EOH
        destination = "local/file.env"
        env         = true
    }
     template{
        data= <<EOH
server=/ducamps.win/192.168.1.10
{{range service "consul"}}server=/consul/{{.Address}}#8600
{{end}}
local-ttl=2
        EOH
        destination="local/dnsmasq.d/02-localresolver.conf"
        change_mode = "restart"

      }
      resources {
        memory = 200
      }
    }
  }
}
