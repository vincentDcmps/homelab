job "crowdsec-api" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "-1"
  }
  vault{
    policies = ["access-tables"]
  }
  group "crowdsec-api" {
    network {
      mode = "host"
      port "http" {
        to = 8080
      }
      port "metric"{
        to = 6060
      }
    }
    task "crowdsec-api" {
       service {
        name= "crowdsec-metrics"
        port = "metric"
        tags = [
        ]
      }
     driver = "docker"
      service {
        name= "crowdsec-api"
        port = "http"
        tags = [

        ]
      }
      config {
        image ="crowdsecurity/crowdsec"
        ports = ["http","metric"]
        volumes = [
          "/mnt/diskstation/nomad/crowdsec/db:/var/lib/crowdsec/data",
          "/mnt/diskstation/nomad/crowdsec/data:/etc/crowdsec_data",
        ]

      }
      template {
        data = <<EOH
DISABLE_AGENT = "true"
{{with secret "secrets/data/crowdsec"}}
  AGENT_USERNAME = "{{.Data.data.AGENT_USERNAME}}"
  AGENT_PASSWORD = "{{.Data.data.AGENT_PASSWORD}}"
{{end}}
EOH
        destination ="secret/api.env"
        env = "true"
      }
      resources {
        memory = 99
      }
    }
    


  }
}
