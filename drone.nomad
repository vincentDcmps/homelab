job "drone" {
  datacenters = ["homelab"]
  type = "service"
  vault {
    policies = ["access-tables"]
  }


  group "droneCI" {
    network {
      mode = "host"
      port "http" {
        to = 80
      }
    }
    constraint {
      attribute = "${attr.cpu.arch}"
      value = "amd64"
    }
    task "drone-server" {
      driver = "docker"
      service {
        name = "drone"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=DroneCI",
          "homer.service=Platform",
          "homer.logo=https://drone.ducamps.win/static/media/logo.76c744d4.svg",
          "homer.target=_blank",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.win",

          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.middlewares.httpsRedirect.redirectscheme.scheme=https",
          "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=httpsRedirect"

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
      resources {
        memory = 100
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
      resources {
        memory = 50
      }
    }

  }
  group "Drone-ARM-Runner" {
    constraint {
      attribute = "${attr.cpu.arch}"
      value = "arm"
    }
    task "drone-ARM-runner"{
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
      resources {
        memory = 50
      }
    }

  }
}
