
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
        tags = ["pihole", "admin"]
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
        server=/consul/172.17.0.1#8600
        EOH
        destination="local/dnsmasq.d/02-localresolver.conf"

      }
    }
  }
}