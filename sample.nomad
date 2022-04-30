
job "sample" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  group "sample"{
    network {
      mode = "host"
      port "http" {
        to = 0000
      }
    }
    vault{
      policies= ["policy_name"]

    }
    task "server" {
      driver = "docker"
      service {
        name = "sample"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "sample"
        ports = ["http"]
        volumes = [
          "/local/sample:/media"
        ]

      }
      env {
      }

      template {
        data= <<EOH
          {{ with secret "secrets/data/sample"}}
          {{end}}
          EOH
        destination = "secrets/sample.env"
        env = true
      }
    }

  }
}
