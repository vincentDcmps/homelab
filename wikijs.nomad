job "wikijs" {
  datacenters = ["homelab"]
  type = "service"
   constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

 meta {
    forcedeploy = "3"
  }
  group "wikijs"{
    network {
      mode = "host"
      port "http" {
        to = 3000
      }
    }
    vault{
      policies= ["access-tables"]

    }
    task "wikijs" {
      driver = "docker"
      service {
        name = "wikijs"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "ducampsv/wikijs"
        ports = ["http"]
        volumes = [
        ]

      }
      env {
      }

      template {
        data= <<EOH
{{ with secret "secrets/data/wikijs"}}
DB_TYPE="postgres"
DB_HOST="db1.ducamps.win"
DB_PORT="5432"
DB_USER="wikijs"
DB_PASS="{{.Data.data.DB_PASS}}"
DB_NAME="wikijs"
{{end}}
EOH
        destination = "secrets/wikijs.env"
        env = true
      }
      resources {
        cpu = 600
        memory = 400
      }
    }

  }
}
