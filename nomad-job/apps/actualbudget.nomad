
job "actualbudget" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  } 
  vault {
  }
  
  group "actualbudget"{
    network {
      mode = "host"
      port "http" {
        to = 5006
      }
    }
    task "actualbudget-server" {
      driver = "docker"
      service {
        name = "actualbudget"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`budget.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=budget.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
            "homer.enable=true",
            "homer.name=${NOMAD_TASK_NAME}",
            "homer.service=Application",
            "homer.target=_blank",
            "homer.logo=https://budget.ducamps.eu/apple-touch-icon.png",
            "homer.url=https://budget.ducamps.eu",

        ]
      }
      config {
        image = "ghcr.service.consul:5000/actualbudget/actual:25.9.0"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/actualbudget:/data"
        ]

      }
      env {
        ACTUAL_OPENID_DISCOVERY_URL = "https://auth.ducamps.eu/.well-known/openid-configuration"
        ACTUAL_OPENID_CLIENT_ID = "actual-budget"
        ACTUAL_OPENID_SERVER_HOSTNAME = "https://budget.ducamps.eu"
        ACTUAL_OPENID_AUTH_METHOD = "oauth2"
      }
      template {
        data        = <<EOH
{{ with secret "secrets/data/authelia/actualbudget"}}ACTUAL_OPENID_CLIENT_SECRET= "{{ .Data.data.password }}" {{end}}
          EOH
        destination = "secrets/var.env"
        env         = true
      }

      resources {
        memory = 300
      }
    }

  }
}
