
job "pdns-auth" {
  datacenters = ["homelab"]
  priority    = 100
  meta {
    force = 3
  }
  type = "service"
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }
  group "pdns-auth" {
    network {
      port "dns" {
        static=5300
      }
      port "http" {
        static = 8081
      }
      port "pdnsadmin"{
        to = 80
      }
    }
  vault {
    policies = ["pdns"]
  }
  task "pdns-auth" {

    driver = "docker"
    service {
        name = "pdns-auth"
        port = "dns"

      }
      config {
        image = "powerdns/pdns-auth-48:latest"        
        network_mode = "host"
        privileged=true
        cap_add= ["NET_BIND_SERVICE"]
        volumes = [
          "/mnt/diskstation/nomad/pdns-auth/var:/var/lib/powerdns/",
          "local/dnsupdate.conf:/etc/powerdns/pdns.d/dnsupdate.conf",
          "local/pdns.conf:/etc/powerdns/pdns.conf"
        ]
      }
      template {
        destination = "secrets/env"

        data = <<EOH
{{ with secret "secrets/data/nomad/pdns"}}
          PDNS_AUTH_API_KEY="{{.Data.data.API_KEY}}"
{{ end }}
        EOH
        env = true
      }
      template{
        destination = "local/dnsupdate.conf"
        data = <<EOH
dnsupdate=yes
allow-dnsupdate-from=192.168.1.41/24
local-port=5300
        EOH
      }
      template{
        destination = "local/pdns.conf"
        data = <<EOH
launch=gpgsql
gpgsql-host=active.db.service.consul
gpgsql-port=5432
gpgsql-user=pdns-auth
{{ with secret "secrets/data/database/pdns"}}
gpgsql-password={{ .Data.data.pdnsauth }}
{{ end }}
include-dir=/etc/powerdns/pdns.d
        EOH
      }
      resources {
        memory = 100
      }
    }
  task "pnds-admin" {
    service {
      name = "pdns-admin"
      tags = [
        "homer.enable=true",
        "homer.name=PDNS-ADMIN",
        "homer.service=Application",
        "homer.target=_blank",
        "homer.url=http://${NOMAD_ADDR_pdnsadmin}",

      ]
      port = "pdnsadmin"
    }
    driver = "docker"
    config {
     image = "powerdnsadmin/pda-legacy:latest"        
     ports= ["pdnsadmin"]  
      volumes = [
        "/mnt/diskstation/nomad/pdns-admin/:/data/node_module/",
      ]
      }
      template{
        destination = "secrets/pdns-admin.env"
        env = true
        data = <<EOH
{{ with secret "secrets/data/nomad/pdns"}}
SECRET_KEY="{{ .Data.data.SECRET_KEY }}"
GUNICORN_WORKERS=2
{{ end }}
{{ with secret "secrets/data/database/pdns"}}
SQLALCHEMY_DATABASE_URI=postgresql://pdns-admin:{{ .Data.data.pdnsadmin }}@active.db.service.consul/pdns-admin
{{end}}
        EOH
      }

  }
  task "keepalived" {
    driver = "docker"
      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      env {
        KEEPALIVED_ROUTER_ID     = "52"
        KEEPALIVED_STATE         = "MASTER"
        KEEPALIVED_VIRTUAL_IPS   = "192.168.1.5"
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
