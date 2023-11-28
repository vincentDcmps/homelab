
job "promtail" {
  datacenters = ["homelab", "hetzner"]
  priority    = 50
  type        = "system"
  meta {
    forcedeploy = "0"
  }

  group "promtail" {
    network {
      mode = "host"
      port "http" {
        static = 3200
      }
    }
    task "promtail" {
      driver = "docker"
      service {
        name = "promtail"
        port = "http"
        check {
          name     = "Promtail HTTP"
          type     = "http"
          path     = "/targets"
          interval = "5s"
          timeout  = "2s"

          check_restart {
            limit           = 2
            grace           = "60s"
            ignore_warnings = false
          }
        }
      }
      config {
        image = "grafana/promtail"
        ports = ["http"]
        args = [
          "-config.file=/local/promtail.yml",
          "-server.http-listen-port=${NOMAD_PORT_http}",
        ]
        volumes = [
          "/opt/nomad/:/nomad/"
        ]

      }
      env {
        HOSTNAME = "${attr.unique.hostname}"
      }
      template {
        data        = <<EOTC
positions:
  filename: {{ env "NOMAD_ALLOC_DIR"}}/positions.yaml
clients:
  - url: http://loki.service.consul:3100/loki/api/v1/push
scrape_configs:
- job_name: 'nomad-logs'
  consul_sd_configs:
    - server: 'consul.service.consul:8500'
  relabel_configs:
    - source_labels: [__meta_consul_service_metadata_external_source]
      regex: nomad
      action: keep
    - source_labels: [__meta_consul_service]
      regex: nomad|nomad-client
      action: drop
    - source_labels: [__meta_consul_node]
      target_label: __host__
    - source_labels: [__meta_consul_service_metadata_external_source]
      target_label: source
      regex: (.*)
      replacement: '$1'
    - source_labels: [__meta_consul_service_id]
      regex: '_nomad-task-([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})-.*'
      target_label:  'alloc_id'
      replacement: '$1'
    - source_labels: [__meta_consul_service]
      target_label: service
    - source_labels: ['__meta_consul_node']
      regex:         '(.*)'
      target_label:  'instance'
      replacement:   '$1'
    - source_labels: [__meta_consul_service_id]
      regex: '_nomad-task-([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})-.*'
      target_label:  '__path__'
      replacement: '/nomad/alloc/$1/alloc/logs/*std*.{?,??}'
  pipeline_stages:
    - match:
        selector: '{source="nomad"}'
        stages:
          - regex:
              source: filename
              expression: '\/nomad\/alloc\/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\/alloc\/logs\/(?P<task_file>[-_\w]*)\.std.*\.\d*'
          - labels:
              task_file:
EOTC
        destination = "/local/promtail.yml"
      }
      resources {
        memory = 100
      }
    }
  }
}
