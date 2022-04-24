job "drone" {
  datacenters = ["homelab"]
  type = "service"

  group "droneCI" {
    network {
      mode = "host"
      port "http" {
        to = 80
      }
    }
    vault {
      policies = ["access-tables"]
    }
    task "drone-server" {
      driver = "docker"
      service {
        name = "drone"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}_insecure.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
        ]
      }
      config {
        image = "drone/drone:latest"
        ports = [
          "http"
        ]
      }
      env {

      }
      template {
        data= <<EOH
          {{ with secret "secrets/data/droneCI"}}
          DRONE_GITEA_SERVER="https://git.ducamps.win"
          DRONE_GITEA_CLIENT_ID="{{ .Data.data.DRONE_GITEA_CLIENT_ID }}"
          DRONE_GITEA_CLIENT_SECRET="{{ .Data.data.DRONE_GITEA_CLIENT_SECRET }}"
          DRONE_GITEA_ALWAYS_AUTH="True"
          DRONE_USER_CREATE="username:vincent,admin:true"
          DRONE_DATABASE_DRIVER="postgres"
          DRONE_DATABASE_DATASOURCE="postgres://drone:{{ .Data.data.DRONE_DB_PASSWORD }}@db1.ducamps.win:5432/drone?sslmode=disable"
          DRONE_RPC_SECRET="{{ .Data.data.DRONE_RPC_SECRET }}"
          DRONE_SERVER_HOST="drone.ducamps.win"
          DRONE_SERVER_PROTO="https"
          {{end}}
          EOH
        destination = "local/drone.env"
        env = true
      }
    }

    task "drone-runner"{
      driver = "docker"
      config {
        image = "drone/drone-runner-docker:latest"
        volumes =[
          "/var/run/docker.sock:/var/run/docker.sock",
        ]
      }
      env {

      }
      template {
        data= <<EOH
          {{ with secret "secrets/data/droneCI"}}
          DRONE_RPC_HOST="drone.ducamps.win"
          DRONE_RPC_PROTO="https"
          DRONE_RPC_SECRET= "{{ .Data.data.DRONE_RPC_SECRET}}"
          {{ end }}
          EOH
        destination = "local/drone-runner.env"
        env = true
      }
    }

  }
}
