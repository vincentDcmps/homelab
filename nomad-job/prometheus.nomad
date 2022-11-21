job "prometheus" {
  datacenters = ["homelab"]
  type        = "service"
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }


  group "prometheus" {
    count = 1

    network {
      port "prometheus_ui" {
        static = 9090
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }
    vault {
      policies = ["prometheus"]
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

        data = <<EOH
---
global:
  scrape_interval:     10s
  evaluation_interval: 10s
alerting:
  alertmanagers:
  - consul_sd_configs:
    - server: 'consul.service.consul:8500'
      services: ['alertmanager']
rule_files:
  - "nomad-alert-rules.yml"

scrape_configs:

  - job_name: 'nomad_metrics'

    consul_sd_configs:
    - server: 'consul.service.consul:8500'
      services: ['nomad-client', 'nomad']

    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep

    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
  - job_name: 'traefik-local'
    consul_sd_configs:
    - server: 'consul.service.consul:8500'
      services: ['traefik-local-admin','traefik-admin']
  - job_name: 'alertmanager'
    consul_sd_configs:
    - server: 'consul.service.consul:8500'
      services: ['alertmanager']

  - job_name: 'crowdsec'
    consul_sd_configs:
    - server: 'consul.service.consul:8500'
      services: ['crowdsec-metrics']
    relabel_configs:
    - source_labels: [__meta_consul_node]
      target_label: machine
  - job_name: 'nodeexp'
    static_configs:
    consul_sd_configs:
    - server: 'consul.service.consul:8500'
      services: ['node-exporter']
    relabel_configs:
      - source_labels: [__meta_consul_node]
        target_label: instance
  - job_name: 'HASS'
    consul_sd_configs:
    - server: 'consul.service.consul:8500'
      services: ['hass']
    relabel_configs:
      - source_labels: ['__meta_consul_dc']
        target_label: instance
    scrape_interval: 60s
    metrics_path: /api/prometheus
    authorization:
      credentials: {{ with secret "secrets/data/nomad/prometheus"}}'{{ .Data.data.hass_token }}'{{end}}





EOH
      }
      template {
        destination     = "local/nomad-alert-rules.yml"
        right_delimiter = "]]"
        left_delimiter  = "[["
        data            = <<EOH
---
groups:
- name: nomad_alerts
  rules:
  - alert: NomadJobFailed
    expr: nomad_nomad_job_summary_failed > 0
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: Nomad job failed (instance {{ $labels.instance }})
      description: "Nomad job failed\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
  - alert: NomadBlockedEvaluation
    expr: nomad_nomad_blocked_evals_total_blocked > 0
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: Nomad blocked evaluation (instance {{ $labels.instance }})
      description: "Nomad blocked evaluation\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
  - alert: NomadJobLost
    expr: nomad_nomad_job_summary_lost > 0
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: Nomad job lost (instance {{ $labels.instance }})
      description: "Nomad job lost\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
  - alert: NomadJobQueued
    expr: nomad_nomad_job_summary_queued > 0
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: Nomad job queued (instance {{ $labels.instance }})
      description: "Nomad job queued\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"


EOH
      }

      driver = "docker"

      config {
        image = "prom/prometheus:latest"
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--storage.tsdb.retention.time=15d",
        ]
        volumes = [
          "local/nomad-alert-rules.yml:/etc/prometheus/nomad-alert-rules.yml",
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "/mnt/diskstation/nomad/prometheus:/prometheus"
        ]

        ports = ["prometheus_ui"]
      }

      service {
        name = "prometheus"
        tags = ["urlprefix-/",
          "homer.enable=true",
          "homer.name=Prometheus",
          "homer.service=Monitoring",
          "homer.type=Prometheus",
          "homer.logo=https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Prometheus_software_logo.svg/173px-Prometheus_software_logo.svg.png",
          "homer.target=_blank",
          "homer.url=http://${NOMAD_ADDR_prometheus_ui}",


        ]
        port = "prometheus_ui"

        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
      resources {
        memory = 250
      }
    }
  }
}
