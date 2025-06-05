job "vector" {
  datacenters = ["homelab", "hetzner"]
  priority    = 50
  type        = "system"
  meta {
    forcedeploy = "0"
  }
  group "vector" {
    count = 1
    network {
      port api {
        to = 8686
      }
    }
    task "vector" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/timberio/vector:0.47.0-alpine"
        ports = ["api"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
        ]

      }
      # docker socket volume mount
      env {
        VECTOR_CONFIG = "local/vector.toml"
        VECTOR_REQUIRE_HEALTHY = "true"
      }
      # resource limits are a good idea because you don't want your log collection to consume all resources available
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }
      # template with Vector's configuration
      template {
        destination = "local/vector.toml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        # overriding the delimiters to [[ ]] to avoid conflicts with Vector's native templating, which also uses {{ }}
        left_delimiter = "[["
        right_delimiter = "]]"
        data=<<EOH
          data_dir = "alloc/data/vector/"
          [api]
            enabled = true
            address = "0.0.0.0:8686"
            playground = true
          [sources.logs]
            type = "docker_logs"
            exclude_containers= ["loki"]
          [sources.podman_logs]
          type = "docker_logs"
          docker_host = "unix:///var/run/podman/podman.sock"
          [sinks.loki]
            type = "loki"
            inputs = ["logs","podman_logs"]
            endpoint = "http://[[ range service "loki" ]][[ .Address ]]:[[ .Port ]][[ end ]]"
            encoding.codec = "json"
            healthcheck.enabled = true
            # since . is used by Vector to denote a parent-child relationship, and Nomad's Docker labels contain ".",
            # we need to escape them twice, once for TOML, once for Vector
            labels.source = 'vector'
            labels.job = '{{ label."com.hashicorp.nomad.job_name" }}'
            labels.task = '{{ label."com.hashicorp.nomad.task_name" }}'
            labels.group = '{{ label."com.hashicorp.nomad.task_group_name" }}'
            labels.namespace = '{{ label."com.hashicorp.nomad.namespace" }}'
            labels.node = '{{ label."com.hashicorp.nomad.node_name" }}'
            # remove fields that have been converted to labels to avoid having the field twice
            remove_label_fields = true
        EOH
      }
      service {
        check {
          port     = "api"
          type     = "http"
          path     = "/health"
          interval = "30s"
          timeout  = "5s"
        }
      }
      kill_timeout = "30s"
    }
  }


}
