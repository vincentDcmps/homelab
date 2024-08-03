
job "pdns-auth" {
  datacenters = ["homelab"]
  priority    = 100
  meta {
    force = 2
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
        image = "docker.service.consul:5000/powerdns/pdns-auth-master:latest"        
        network_mode = "host"
        privileged=true
        cap_add= ["net_bind_service"]
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
allow-dnsupdate-from=192.168.1.43/24
local-address=192.168.1.5
local-port=53
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
resolver=192.168.1.6
expand-alias=yes
include-dir=/etc/powerdns/pdns.d
        EOH
      }
      resources {
        cpu    = 50
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
        "homer.logo=http://${NOMAD_ADDR_pdnsadmin}/static/img/favicon.png",
        "homer.target=_blank",
        "homer.url=http://${NOMAD_ADDR_pdnsadmin}",

      ]
      port = "pdnsadmin"
    }
    driver = "docker"
    config {
     image = "docker.service.consul:5000/powerdnsadmin/pda-legacy:latest"        
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
    resources {
      cpu    = 50
      memory = 200
}

  }
  task "pdns-recursor" {

    driver = "docker"
    config {
     image = "docker.service.consul:5000/powerdns/pdns-recursor-master:latest"        
    network_mode = "host"
      volumes = [
        "local/recursor.conf:/etc/powerdns/recursor.conf",
      ]
    }
    template{
      destination = "local/recursor.conf"
      data= <<EOH
config-dir=/etc/powerdns
dnssec=off
forward-zones=consul=127.0.0.1:8600,ducamps.eu=192.168.1.5,1.168.192.in-addr.arpa=192.168.1.5
local-address=192.168.1.6
      EOH
    }
    resources {
      cpu    = 50
      memory = 50
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
        KEEPALIVED_VIRTUAL_IPS   = "#PYTHON2BASH:['192.168.1.5','192.168.1.6']"
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
        image        = "docker.service.consul:5000/osixia/keepalived:2.0.20"
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
