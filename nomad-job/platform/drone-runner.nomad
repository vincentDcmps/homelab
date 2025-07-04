
job "drone-runner" {
  datacenters = ["homelab"]
  priority = 50
  type = "system"
  meta {
    forcedeploy = "0"
  }

  group "drone-runner"{
    vault{
      policies= ["droneci"]

    }
  
    task "drone-runner" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/drone/drone-runner-docker:1.8"
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
        ]
      }
      env {

      }
      template {
        data        = <<EOH
          {{ with secret "secrets/data/nomad/droneci"}}
          DRONE_RPC_HOST="drone.ducamps.eu"
          DRONE_RPC_PROTO="https"
          DRONE_RPC_SECRET= "{{ .Data.data.DRONE_RPC_SECRET}}"
          DRONE_SECRET_PLUGIN_TOKEN={{ .Data.data.DRONE_VAULT_SECRET}}
          {{ end }}
          {{- range service "drone-vault" }}
          DRONE_SECRET_PLUGIN_ENDPOINT=http://{{ .Address }}:{{ .Port }}
          {{- end}}
          EOH
        destination = "local/drone-runner.env"
        env         = true
      }
      resources {
        memory = 50
      }
    }

  }
}
