
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
        image = "ghcr.service.consul:5000/actualbudget/actual:25.6.1"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/actualbudget:/data"
        ]

      }
      env {
      }

      resources {
        memory = 300
      }
    }

  }
}
