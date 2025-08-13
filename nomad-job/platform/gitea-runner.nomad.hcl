
job "gitea-runner" {
  datacenters = ["homelab"]
  priority = 50
  type = "system"
  meta {
    forcedeploy = "0"
  }

  group "gitea-runner"{
  
    task "gitea-runner" {
      vault {
        policies=["nomad-workload"]
      }
      driver = "docker"
      config {
        image = "docker.service.consul:5000/gitea/act_runner:0.2.11"
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
        ]
      }
      env {

      }
      template {
        data        = <<EOH
GITEA_INSTANCE_URL="https://git.ducamps.eu"
{{ with secret "secrets/data/nomad/gitea-runner"}}
GITEA_RUNNER_REGISTRATION_TOKEN="{{ .Data.data.token }}"
{{ end }}
EOH
        destination = "local/gitea-runner.env"
        env         = true
      }
      resources {
        memory = 100
        memory_max = 300
      }
    }

  }
}
