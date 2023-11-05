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
      policies= ["wikijs"]

    }
    task "wikijs" {
      driver = "docker"
      service {
        name = "wikijs"
        port = "http"
        tags = [
            "homer.enable=true",
            "homer.name=wikiJS",
            "homer.service=Application",
            "homer.subtitle=projet Infotech",
            "homer.logo=https://repository-images.githubusercontent.com/65848095/7655d480-b066-11e9-991b-81088c474331",
            "homer.target=_blank",
            "homer.url=https://${NOMAD_JOB_NAME}.ducamps.eu",

            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
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
{{ with secret "secrets/data/database/wikijs"}}
DB_TYPE="postgres"
DB_HOST="active.db.service.consul"
DB_PORT="5432"
DB_USER="wikijs"
DB_PASS="{{.Data.data.password}}"
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
