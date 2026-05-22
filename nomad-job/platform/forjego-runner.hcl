
job "forjego-runner" {
  datacenters = ["homelab"]
  priority = 50
  type = "system"
  meta {
    forcedeploy = "0"
  }


  group "forjego-runner"{
    network {
      mode  = "bridge"
    }
    task dind {
      driver=  "docker"
      config {
        ports= ["dind"]
        image = "docker:dind"
        privileged = true
        command  = "dockerd"
        args = ["-H","tcp://localhost:2375","--tls=false"]
      }

      lifecycle {
          hook = "prestart"
          sidecar = true
      }
      
  }
    task "forjego-runner" {
      vault {
        policies=["nomad-workload"]
      }
      driver = "docker"
      config {
        image = "data.forgejo.org/forgejo/runner:12"
        volumes = [
          "/var/local/forjego_runner:/data",
        ]
        command = "forgejo-runner"
        args= ["daemon", "--config", "/local/runner-config.yml"]
      }
      template {
        data        = <<EOH
        {{ $host := env "node.unique.name" }}
        {{  with secret (print "secrets/data/nomad/forjego-runner/" $host)  }}
          server:
            connections:
              forgejo:
                url: https://git.ducamps.eu/
                uuid: {{ .Data.data.uuid }}
                token: {{ .Data.data.token }}
                labels:
                  - ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04
        {{ end }}
        EOH
        destination = "local/runner-config.yml"
      }
      template {
        data = <<EOH
DOCKER_HOST=tcp://localhost:2375
        EOH
        destination = "local/runner-env"
        env = true
      }
      resources {
        memory = 100
        memory_max = 500
      }
    }

  }
}
