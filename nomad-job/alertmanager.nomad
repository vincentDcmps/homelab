
job "alertmanager" {
  datacenters = ["homelab"]
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  vault {
    policies = ["alertmanager"]
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  group "alertmanager" {
    network {
      mode = "host"
      port "http" {
        static = 9093
      }
    }
    task "alertmanager" {
      driver = "docker"
      service {
        name = "alertmanager"
        port = "http"
        tags = [
          "urlprefix-/alertmanager strip=/alertmanager",
          "homer.enable=true",
          "homer.name=AlertManager",
          "homer.service=Monitoring",
          "homer.logo=http://${NOMAD_ADDR_http}/favicon.ico",
          "homer.target=_blank",
          "homer.url=http://${NOMAD_ADDR_http}",

        ]
        check {
          name     = "alertmanager_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image = "docker.service.consul:5000/prom/alertmanager"
        args= ["--log.level=debug", "--config.file=/etc/alertmanager/alertmanager.yml"]
        ports = ["http"]
        volumes = [
          "local/alertmanager.yml:/etc/alertmanager/alertmanager.yml"
        ]
      }

      template {
        data = <<EOH
global:
  smtp_from: alert@ducamps.eu
  smtp_smarthost: mail.ducamps.eu:465
  smtp_hello: "mail.ducamps.eu"
  smtp_require_tls: false
  {{with secret "secrets/data/nomad/alertmanager/mail"}}
  smtp_auth_username: {{.Data.data.username}}
  smtp_auth_password: {{.Data.data.password}}
  {{end}}
route:
  group_by: ['alertname']
  receiver: "default"
receivers:
  - name: "default"
    email_configs:
      - send_resolved: true
        to: "vincent@ducamps.eu"
EOH
        destination = "local/alertmanager.yml"
      }
      resources {
        memory = 75
      }
    }
  }
}
