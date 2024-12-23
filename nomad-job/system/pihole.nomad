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
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
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
        "homer.logo=http://192.168.1.4:${NOMAD_PORT_http}/admin/img/logo.svg",
        "homer.target=_blank",
        "homer.url=http://192.168.1.4:${NOMAD_PORT_http}/admin",

      ]
      port = "http"
    }
    task "server" {
      driver = "docker"
     service {
        name = "dns"
        port = "dns"

      }
      config {
        image = "docker.service.consul:5000/pihole/pihole:2023.10.0"
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
        DNS1 = "192.168.1.5"
        DNS2 = "192.168.1.40"
        WEB_PORT      = "${NOMAD_PORT_http}"

      }
      template {
        data        = <<EOH
        INTERFACE     = {{ sockaddr "GetPrivateInterfaces | include \"network\" \"192.168.1.0/24\" | attr \"name\"" }}
        FTLCONF_LOCAL_IPV4 = 192.168.1.4
        WEBPASSWORD="{{with secret "secrets/data/nomad/pihole"}}{{.Data.data.WEBPASSWORD}}{{end}}"
        EOH
        destination = "local/file.env"
        change_mode = "noop"
        env         = true
      }
      template {
        data        = <<EOH
{{range service "consul"}}server=/consul/{{.Address}}#8600
{{end}}
domain=ducamps.eu
no-negcache
listen-address=192.168.1.4
bind-interfaces
local-ttl=2
        EOH
        destination = "local/dnsmasq.d/02-localresolver.conf"
        change_mode = "restart"

      }
      resources {
        memory = 100
        memory_max =200
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
