job "grafana" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  meta {
    forcedeploiement = 2
  }

  vault {
    policies = ["grafana"]
  }
  group "grafana" {
    network {
      port "http" {
        to = 3000
      }
    }
    service {
      name = "grafana"
      port = "http"
      tags = [
        "homer.enable=true",
        "homer.name=Grafana",
        "homer.service=Monitoring",
        "homer.logo=https://grafana.ducamps.eu/public/img/grafana_icon.svg",
        "homer.target=_blank",
        "homer.url=https://${NOMAD_JOB_NAME}.ducamps.eu",

        "traefik.enable=true",
        "traefik.http.routers.grafana.entryPoints=websecure",
        "traefik.http.routers.grafana.rule=Host(`grafana.ducamps.eu`)",
        "traefik.http.routers.grafana.tls.domains[0].sans=grafana.ducamps.eu",
        "traefik.http.routers.grafana.tls.certresolver=myresolver",
        "traefik.http.routers.grafana.entrypoints=web,websecure",

      ]
    }

    task "dashboard" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/grafana/grafana"
        ports = ["http"]
        volumes = [
          "local/grafana.ini:/etc/grafana/grafana.ini",
          "/mnt/diskstation/nomad/grafana/lib:/var/lib/grafana"
        ]
      }
      template {
        data = <<EOH
force_migration=true 
[server]
root_url = https://grafana.ducamps.eu
[auth.generic_oauth]
enabled = true
name = Authelia
icon = signin
client_id = grafana
client_secret = {{ with secret "secrets/data/authelia/grafana"}} {{ .Data.data.password }} {{end}}
scopes = openid profile email groups
empty_scopes = false
auth_url = https://auth.ducamps.eu/api/oidc/authorization
token_url = https://auth.ducamps.eu/api/oidc/token
api_url = https://auth.ducamps.eu/api/oidc/userinfo
login_attribute_path = preferred_username
groups_attribute_path = groups
name_attribute_path = name
use_pkce = true
role_attribute_path=contains(groups[*], 'GrafanaAdmins') && 'Admin' || contains(groups[*], 'GrafanaUsers') && 'Viewer'
EOH
        destination = "local/grafana.ini"
      }
      resources {
        memory = 250
      }
    }
  }
}
