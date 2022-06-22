
job "crowdsec-agent" {
  datacenters = ["homelab","hetzner"]
  type = "system"
  meta {
    forcedeploy = "2"
  }
  vault{
    policies= ["access-tables"]

  }

  group "crowdsec-agent"{
    network {
      mode = "host"
      port "metric"{
        to = 6060
      }
    }
    task "crowdsec-agent" {
      service {
        name= "crowdsec-metrics"
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
        COLLECTIONS= "crowdsecurity/traefik crowdsecurity/home-assistant LePresidente/gitea"
        DISABLE_LOCAL_API= "true"
      }
      template {
        data = <<EOH
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
  type: docker
  program: gitea


EOH
        destination = "local/acquis.yaml"

      }
      template {
        data = <<EOH
        LOCAL_API_URL =  {{- range service "crowdsec-api" }} "http://{{ .Address }}:{{ .Port }}"{{- end }}
AGENT_USERNAME = "{{ env "node.unique.name" }}"
{{with secret "secrets/data/crowdsec"}}
  AGENT_PASSWORD = "{{.Data.data.AGENT_PASSWORD}}"
{{end}}
EOH
        destination ="secret/agent.env"
        env = "true"
      }
      resources {
        memory = 100
      }
    }

  }
}
