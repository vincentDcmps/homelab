
job "pihole" {
  datacenters = ["homelab"]
  priority    = 100
  meta {
    force = 1
  }
  type = "service"
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }
  group "pi-hole" {
    network {
      port "dns" {
        static = 53
      }
      port "http" {
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
     service {
        name = "dns"
        port = "dns"

        check {
          name     = "service: dns tcp check"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"

          success_before_passing   = "3"
          failures_before_critical = "3"
        }

        check {
          name     = "service: dns dig check"
          type     = "script"
          command  = "/usr/bin/dig"
          args     = ["+short", "@127.0.0.1"]
          interval = "10s"
          timeout  = "2s"

          check_restart {
            limit = 3
            grace = "60s"
          }
        }
      }
      config {
        image = "pihole/pihole:latest"
        network_mode = "host"
        volumes = [
          "local/dnsmasq.d/02-localresolver.conf:/etc/dnsmasq.d/02-localresolver.conf",
          "/mnt/diskstation/nomad/pihole:/etc/pihole"
        ]

      }
      vault {
        policies = ["pihole"]

      }
      env {
        TZ   = "Europe/Paris"
        DNS1 = "1.1.1.1"
        DNS2 = "80.67.169.40"
        WEB_PORT      = "${NOMAD_PORT_http}"

      }
      template {
        data        = <<EOH
        INTERFACE     = {{ sockaddr "GetPrivateInterfaces | include \"network\" \"192.168.1.0/24\" | attr \"name\"" }}
        FTLCONF_LOCAL_IPV4 = {{ env "NOMAD_IP_dns" }}
        WEBPASSWORD="{{with secret "secrets/data/nomad/pihole"}}{{.Data.data.WEBPASSWORD}}{{end}}"
        EOH
        destination = "local/file.env"
        change_mode = "noop"
        env         = true
      }
      template {
        data        = <<EOH
server=/ducamps.win/192.168.1.10
server=/ducamps.eu/192.168.1.10
{{range service "consul"}}server=/consul/{{.Address}}#8600
{{end}}
domain=ducamps.win
no-negcache
local-ttl=2
        EOH
        destination = "local/dnsmasq.d/02-localresolver.conf"
        change_mode = "restart"

      }
      resources {
        memory = 100
      }
    }

    task "keepalived" {
      driver = "docker"

      lifecycle {
        hook    = "poststart"
        sidecar = true
      }

      env {
        KEEPALIVED_ROUTER_ID     = "53"
        KEEPALIVED_STATE         = "MASTER"
        KEEPALIVED_VIRTUAL_IPS   = "192.168.1.4"
      }
      template{
        destination = "local/env.yaml"
        change_mode = "restart"
        env= true
        data = <<EOH
        KEEPALIVED_INTERFACE= {{ sockaddr "GetPrivateInterfaces | include \"network\" \"192.168.1.0/24\" | attr \"name\"" }}
        EOH
      }
      config {
        image        = "osixia/keepalived:2.0.20"
        network_mode = "host"
        cap_add = [
          "NET_ADMIN",
          "NET_BROADCAST",
          "NET_RAW"
        ]
      }

      resources {
        cpu    = 20
        memory = 20
      }
    }

  }
}
