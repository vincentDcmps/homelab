
job "supysonic" {
  datacenters = ["homelab"]
  priority    = 90
  type        = "service"
  meta {
    forcedeploy = "1"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "supysonic" {
    network {
      mode = "host"
      port "fcgi" {
        to = 5000
      }
      port "http" {
        to = 80
      }
    }
    vault {
      policies = ["supysonic"]

    }
    service {
      name = "supysonic"
      port = "http"
      tags = [
        "homer.enable=true",
        "homer.name=Supysonic",
        "homer.service=Application",
        "homer.icon=fas fa-headphones",
        "homer.target=_blank",
        "homer.url=http://${NOMAD_JOB_NAME}.ducamps.win",

        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
        "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
        "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
        "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


      ]
    }

    task "supysonic-frontend" {
      driver = "docker"
      config {
        image = "nginx:alpine"
        ports = [
          "http"
        ]
        volumes = [
          "etc/nginx/nginx.conf:/etc/nginx/nginx.conf",
        ]
      }
      template {
        data        = <<EOH
worker_processes auto;
pid /var/run/nginx.pid;
events {
  worker_connections  1024;
}

http {
    server {
        listen 80;
        server_name localhost;

        location / {
            try_files $uri @flaskr;
        }
        location @flaskr {
            include fastcgi_params;
            fastcgi_param SCRIPT_NAME "";
            fastcgi_param PATH_INFO $fastcgi_script_name;
            fastcgi_pass {{env "NOMAD_ADDR_fcgi"}};
        }
    }
}
        EOH
        destination = "etc/nginx/nginx.conf"

      }
      resources {
        memory = 75
      }
    }
    task "supysonic-server" {
      driver = "docker"
      config {
        image      = "ducampsv/supysonic:latest"
        ports      = ["fcgi"]
        force_pull = true
        volumes = [
          "/mnt/diskstation/music:/mnt/diskstation/music"
        ]

      }
      env {
        SUPYSONIC_RUN_MODE         = "fcgi-port"
        SUPYSONIC_DAEMON_ENABLED   = "true"
        SUPYSONIC_WEBAPP_LOG_LEVEL = "DEBUG"
        SUPYSONIC_DAEMON_LOG_LEVEL = "INFO"
        SUPYSONIC_LDAP_SERVER      = "LDAP://ldap.ducamps.win"
        SUPYSONIC_LDAP_BASE_DN     = "dc=ducamps,dc=win"
        SUPYSONIC_LDAP_USER_FILTER = "(&(memberOf=CN=SupysonicUsers,cn=groups,dc=ducamps,dc=win))"
        SUPYSONIC_LDAP_ADMIN_FILTER= "(&(memberOf=CN=SupysonicAdmins,cn=groups,dc=ducamps,dc=win))"
      }

      template {
        data        = <<EOH
          {{ with secret "secrets/data/database/supysonic"}}
            SUPYSONIC_DB_URI = "postgres://supysonic:{{ .Data.data.password}}@active.db.service.consul/supysonic"
          {{end}}
          {{ with secret "secrets/data/nomad/supysonic"}}
            SUPYSONIC_LDAP_BIND_DN     = "{{ .Data.data.serviceAccountName }}"
            SUPYSONIC_LDAP_BIND_PASSWORD = "{{ .Data.data.serviceAccountPassword }}"
          {{ end }}
          EOH
        destination = "secrets/supysonic.env"
        env         = true
      }
      resources {
        memory = 256
      }
    }

  }
}
