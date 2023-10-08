
job "crowdsec-agent" {
  datacenters = ["homelab", "hetzner"]
  type        = "system"
  priority    = 50
  meta {
    forcedeploy = "2"
  }
  vault {
    policies = ["crowdsec"]

  }

  group "crowdsec-agent" {
    network {
      mode = "host"
      port "metric" {
        to = 6060
      }
    }
    task "crowdsec-agent" {
      service {
        name = "crowdsec-metrics"
        port = "metric"
        tags = [
        ]
      }
      driver = "docker"
      config {
        image = "crowdsecurity/crowdsec"
        ports = ["metric"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          "/var/log:/var/log",
          "local/acquis.yaml:/etc/crowdsec/acquis.yaml"
        ]

      }
      env {
      COLLECTIONS       = "andreasbrett/paperless-ngx Dominic-Wagner/vaultwarden LePresidente/jellyfin crowdsecurity/traefik crowdsecurity/home-assistant LePresidente/gitea crowdsecurity/postfix  crowdsecurity/dovecot "
      DISABLE_LOCAL_API = "true"
      }
      template {
        data        = <<EOH
---
source: docker
container_name_regexp:
  - jellyfin*
labels:
  type: jellyfin
---
source: docker
container_name_regexp:
  - paperless-ng*
labels:
  type: Paperless-ngx
---
source: docker
container_name_regexp:
  - vaultwarden*
labels:
  type: Vaultwarden
---
source: docker
container_name_regexp:
  - docker-mailserver*
labels:
  type: syslog
---
source: docker
container_name_regexp:
  - traefik-*
labels:
  type: traefik
---
source: docker
container_name_regexp:
  - hass-*
labels:
  type: homeassistant
---
source: docker
container_name_regexp:
  - gitea-*
labels:
  type: gitea


EOH
        destination = "local/acquis.yaml"

      }
      template {
        data        = <<EOH
        LOCAL_API_URL =  {{- range service "crowdsec-api" }} "http://{{ .Address }}:{{ .Port }}"{{- end }}
AGENT_USERNAME = "{{ env "node.unique.name" }}"
{{with secret "secrets/data/nomad/crowdsec"}}
  AGENT_PASSWORD = "{{.Data.data.AGENT_PASSWORD}}"
{{end}}
EOH
        destination = "secret/agent.env"
        env         = "true"
      }
      resources {
        memory = 100
      }
    }

  }
}
