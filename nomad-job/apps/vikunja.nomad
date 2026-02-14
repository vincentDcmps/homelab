
job "vikunja" {
  datacenters = ["homelab"]
  priority    = 70
  type        = "service"
  meta {
    forcedeploy = "0"
  }

  group "vikunja" {
    network {
      mode = "host"
      port "front" {
        to = 80
      }
      port "api" {
        to = 3456
      }
    }
    vault {

    }
    task "api" {
      driver = "docker"
      service {
        name = "vikunja-api"
        port = "api"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}-${NOMAD_TASK_NAME}.entrypoints=web,websecure",
          "homer.enable=true",
          "homer.name=vikunka",
          "homer.service=Application",
          "homer.logo=https://${NOMAD_JOB_NAME}.ducamps.eu/images/icons/apple-touch-icon-180x180.png",
          "homer.target=_blank",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.eu",
        ]
      }
      config {
        image = "docker.service.consul:5000/vikunja/vikunja:1.0.0"
        ports = ["api", "front"]
        volumes = ["local/config.yml:/etc/vikunja/config.yml"]
      }
      env {
        VIKUNJA_DATABASE_HOST       = "active.db.service.consul"
        VIKUNJA_DATABASE_TYPE       = "postgres"
        VIKUNJA_DATABASE_USER       = "vikunja"
        VIKUNJA_DATABASE_DATABASE   = "vikunja"
        VIKUNJA_SERVICE_FRONTENDURL = "https://${NOMAD_JOB_NAME}.ducamps.eu/"
        VIKUNJA_AUTH_LOCAL          = False
      }

      template {
        data        = <<EOH
          {{ with secret "secrets/data/database/vikunja"}}
            VIKUNJA_DATABASE_PASSWORD= "{{ .Data.data.password }}"
          {{end}}
          {{ with secret "secrets/data/nomad/vikunja"}}
            VIKUNJA_SERVICE_JWTSECRET   = "{{ .Data.data.jwtsecret }}"
          {{ end }}
          EOH
        destination = "secrets/sample.env"
        env         = true
      }
      template {
        data        = <<EOH
service:
        publicurl: https://vikunja.ducamps.eu/
auth:
  openid:
    enabled: true
    redirecturl: https://vikunja.ducamps.eu/auth/openid/
    providers:
      - name: Authelia
        authurl: https://auth.ducamps.eu
        clientid: vikunja
        clientsecret: {{ with secret "secrets/data/authelia/vikunja"}} {{ .Data.data.password }} {{end}}
        scope: openid profile email
        EOH
        destination = "local/config.yml"
      }
      resources {
        memory = 100
      }
    }


  }
}
