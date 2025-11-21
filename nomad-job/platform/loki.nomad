
job "loki" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  group "loki" {
    network {
      mode = "host"
      port "http" {
        static = 3100
      }
    }
    task "loki" {
      driver = "docker"
      service {
        name = "loki"
        port = "http"
        check {
          name     = "Loki HTTP"
          type     = "http"
          path     = "/ready"
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
        image = "docker.service.consul:5000/grafana/loki:3.6.0"
        ports = ["http"]
        args = [
          "-config.file",
          "/etc/loki/local-config.yaml",
        ]
        volumes = [
          "/mnt/diskstation/nomad/loki:/loki"
        ]
      }
      template {
        data        = <<EOH
auth_enabled: false
server:
  http_listen_port: 3100

common:
  instance_addr: 127.0.0.1
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: "2023-04-08" # <---- A date in the future
      index:
        period: 24h
        prefix: index_
      object_store: filesystem
      schema: v13
      store: tsdb
compactor:
  retention_enabled: true
  working_directory: /loki/tsdb-shipper-compactor
  shared_store: filesystem
limits_config:
  split_queries_by_interval: 24h
  max_query_parallelism: 100
  max_entries_limit_per_query: 10000
  injection_rate_strategy: local
  retention_period: 90d
  reject_old_samples: true
  reject_old_samples_max_age: 168h
query_scheduler:
  max_outstanding_requests_per_tenant: 4096
querier:
  max_concurrent: 4096
frontend:
  max_outstanding_per_tenant: 4096
query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100
EOH
        destination = "local/loki/local-config.yaml"
      }
      resources {
        memory = 300
        memory_max = 1000
      }
    }

  }
}
