job "crowdsec-api" {
  datacenters = ["homelab"]
  priority    = 50
  type        = "service"
  meta {
    forcedeploy = "-1"
  }
  vault {
    policies = ["crowdsec"]
  }
  group "crowdsec-api" {
    network {
      mode = "host"
      port "http" {
        static = 8898
        to     = 8080
      }
      port "metric" {
        to = 6060
      }
    }
    task "crowdsec-api" {
      service {
        name = "crowdsec-metrics"
        port = "metric"
        tags = [
        ]
      }
      driver = "docker"
      service {
        name = "crowdsec-api"
        port = "http"
        tags = [

        ]
      }
      config {
        image = "crowdsecurity/crowdsec"
        ports = ["http", "metric"]
        volumes = [
          "/mnt/diskstation/nomad/crowdsec/db:/var/lib/crowdsec/data",
          "/mnt/diskstation/nomad/crowdsec/data:/etc/crowdsec_data",
        ]

      }
      template {
        data        = <<EOH
DISABLE_AGENT = "true"
EOH
        destination = "secret/api.env"
        env         = "true"
      }
      resources {
        memory = 99
      }
    }



  }
}
