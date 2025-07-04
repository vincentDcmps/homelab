job "gitea" {
  datacenters = ["homelab"]
  priority    = 90
  type        = "service"
  meta {
    force = 1
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  } 
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
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
          "homer.logo=https://git.ducamps.eu/assets/img/logo.svg",
          "homer.url=https://${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`git.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=git.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.middlewares.httpsRedirect.redirectscheme.scheme=https",
          "traefik.http.routers.${NOMAD_JOB_NAME}.middlewares=httpsRedirect",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",

        ]
      }
      service {
        name = "gitea-ssh"
        port = "ssh"
        tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.gitea-ssh.rule=HostSNI(`*`)",
          "traefik.tcp.routers.gitea-ssh.entrypoints=ssh"
        ]
      }
      config {
        image = "docker.service.consul:5000/gitea/gitea:1.24"
        ports = [
          "http",
          "ssh"
        ]
        volumes = [
          "/mnt/diskstation/nomad/gitea:/data"
        ]
      }
      env {
        USER_UID                             = 1000000
        USER_GID                            = 984
        GITEA__action__ENABLED               = "true"
        GITEA__server__DOMAIN                = "git.ducamps.eu"
        GITEA__server__ROOT_URL              = "https://git.ducamps.eu"
        GITEA__server__SSH_DOMAIN            = "git.ducamps.eu"
        GITEA__server__SSH_PORT              = "2222"
        GITEA__server__SSH_LISTEN_PORT       = "2222"
        GITEA__server__START_SSH_SERVER      = "false"
        GITEA__database__DB_TYPE             = "postgres"
        GITEA__database__HOST                = "active.db.service.consul"
        GITEA__database__NAME                = "gitea"
        GITEA__database__USER                = "gitea"
        GITEA__service__DISABLE_REGISTRATION = "false"
        GITEA__service__ALLOW_ONLY_EXTERNAL_REGISTRATION = "true"
        GITEA__service__SHOW_REGISTRATION_BUTTON = "false"
        GITEA__openid__ENABLE_OPENID_SIGNIN = "false"
        GITEA__openid__ENABLE_OPENID_SIGNUP = "true"
        GITEA__repository__ROOT              = "/data/gitea-repositories"
        GITEA__server__APP_DATA_PATH         = "/data"
        GITEA__server__LFS_CONTENT_PATH      = "/data/lfs"
        GITEA__webhook__ALLOWED_HOST_LIST    = "drone.ducamps.eu"
        GITEA__webhook__DELIVER_TIMEOUT       = "30" 
      }
      template {
        data        = <<EOH
        {{ with secret "secrets/data/nomad/gitea"}}
            GITEA__security__SECRET_KEY = "{{.Data.data.secret_key}}"
            GITEA__oauth2__JWT_SECRET = "{{.Data.data.jwt_secret}}"
            GITEA__security__INTERNAL_TOKEN = "{{.Data.data.internal_token}}"
          {{end}}

          {{ with secret "secrets/data/database/gitea"}}
            GITEA__database__PASSWD = "{{.Data.data.password}}"
          {{end}}
          EOH
        destination = "secrets/gitea.env"
        env         = true
      }
      resources {
        memory = 500
      }
    }
  }
}
