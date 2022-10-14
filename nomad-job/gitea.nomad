job "git" {
  datacenters = ["homelab"]
  type = "service"

  group "gitea" {
    network {
      mode = "host"
      port "http" {
        to = 3000
      }
      port "ssh" {
        to = 22
      }
    }
    vault {
      policies = ["access-tables"]
    }
    task "gitea" {
      driver = "docker"
      service {
        name = "gitea"
        port = "http"
        tags = [
          "homer.enable=true",
          "homer.name=Gitea",
          "homer.service=Platform",
          "homer.target=_blank",
          "homer.logo=https://git.ducamps.win/assets/img/logo.svg",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.win",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.middlewares.httpsRedirect.redirectscheme.scheme=https",
          "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=httpsRedirect"

        ]
      }
      service {
        name= "gitea-ssh"
        port = "ssh"
        tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.gitea-ssh.rule=HostSNI(`*`)",
          "traefik.tcp.routers.gitea-ssh.entrypoints=ssh"
        ]
      }
      config {
        image = "gitea/gitea:latest"
        ports = [
          "http",
          "ssh"
        ]
      volumes = [
        "/mnt/diskstation/git:/repo",
        "/mnt/diskstation/nomad/gitea:/data"
      ]
      }
      env {
        USER_UID = 1000000
        USER_GUID = 985
        GITEA__server__DOMAIN = "git.ducamps.win"
        GITEA__server__ROOT_URL = "https://git.ducamps.win"
        GITEA__server__SSH_DOMAIN  = "git.ducamps.win"
        GITEA__server__SSH_PORT  = "2222"
        GITEA__server__SSH_LISTEN_PORT  = "2222"
        GITEA__server__START_SSH_SERVER  = "false"
        GITEA__database__DB_TYPE = "postgres"
        GITEA__database__HOST = "db1.ducamps.win"
        GITEA__database__NAME = "gitea"
        GITEA__database__USER = "gitea"
        GITEA__service__DISABLE_REGISTRATION = "true"
        GITEA__repository__ROOT = "/repo"
        GITEA__server__APP_DATA_PATH = "/data"
        GITEA__server__LFS_CONTENT_PATH = "/repo/LFS"
        GITEA__webhook__ALLOWED_HOST_LIST = "drone.ducamps.win"
      }
      template {
        data= <<EOH
          {{ with secret "secrets/data/gitea"}}
            GITEA__database__PASSWD = "{{.Data.data.PASSWD}}"
            GITEA__security__SECRET_KEY = "{{.Data.data.secret_key}}"
            GITEA__oauth2__JWT_SECRET = "{{.Data.data.jwt_secret}}"
            GITEA__security__INTERNAL_TOKEN = "{{.Data.data.internal_token}}"
          {{end}}
          EOH
        destination = "secrets/gitea.env"
        env = true
      }
      resources {
        memory = 400
      }
    }
  }
}
