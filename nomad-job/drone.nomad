job "drone" {
  datacenters = ["homelab"]
  type        = "service"
  vault {
    policies = ["droneci"]
  }


  group "droneCI" {
    network {
      mode = "host"
      port "http" {
        to = 80
      }
      port "vault" {
        to= 3000
      }
    }
    constraint {
      attribute = "${attr.cpu.arch}"
      value     = "amd64"
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
        data        = <<EOH
          {{ with secret "secrets/data/nomad/droneCI"}}
          DRONE_GITEA_SERVER="https://git.ducamps.win"
          DRONE_GITEA_CLIENT_ID="{{ .Data.data.DRONE_GITEA_CLIENT_ID }}"
          DRONE_GITEA_CLIENT_SECRET="{{ .Data.data.DRONE_GITEA_CLIENT_SECRET }}"
          DRONE_GITEA_ALWAYS_AUTH="True"
          DRONE_USER_CREATE="username:vincent,admin:true"
          DRONE_DATABASE_DRIVER="postgres"
          DRONE_RPC_SECRET="{{ .Data.data.DRONE_RPC_SECRET }}"
          DRONE_SERVER_HOST="drone.ducamps.win"
          DRONE_SERVER_PROTO="https"
          {{end}}

          {{ with secret "secrets/data/database/droneCI"}}
          DRONE_DATABASE_DATASOURCE="postgres://drone:{{ .Data.data.password }}@db1.ducamps.win:5432/drone?sslmode=disable"
          {{end}}
          EOH
        destination = "secrets/drone.env"
        env         = true
      }
      resources {
        memory = 100
      }
    }
    task "vault" {
      driver = "docker"
      service {
        name = "drone-vault"
        port = "vault"
      }
      config {
        ports = ["vault"]
        image = "drone/vault:latest"
      }
      template {
        data= <<EOH
        DRONE_DEBUG=true
        {{ with secret "secrets/data/nomad/droneCI"}}
        DRONE_SECRET= {{ .Data.data.DRONE_VAULT_SECRET}}
        {{end}}
        VAULT_TOKEN=
        VAULT_ADDR=http://active.vault.service.consul:8200
        VAULT_AUTH_TYPE=approle
        VAULT_TOKEN_TTL=72h
        VAULT_TOKEN_RENEWAL=24h
        {{ with secret "secrets/data/nomad/droneCI/approle"}}
        VAULT_APPROLE_ID=  {{ .Data.data.approleID}}
        VAULT_APPROLE_SECRET=  {{ .Data.data.approleSecretID}}
        {{end}}

        EOH
        destination = "secrets/drone-vault.env"
        env = true

      }


    }
  }
}
