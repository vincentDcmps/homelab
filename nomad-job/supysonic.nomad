
job "supysonic" {
  datacenters = ["homelab"]
  type        = "service"
  meta {
    forcedeploy = "0"
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
      policies = ["access-tables"]

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
        image      = "ogarcia/supysonic:full-sql"
        ports      = ["fcgi"]
        force_pull = true
        volumes = [
          "/mnt/diskstation/music:/mnt/diskstation/music"
        ]

      }
      env {
        SUPYSONIC_RUN_MODE         = "fcgi-port"
        SUPYSONIC_DAEMON_ENABLED   = "true"
        SUPYSONIC_WEBAPP_LOG_LEVEL = "WARNING"
        SUPYSONIC_DAEMON_LOG_LEVEL = "INFO"
      }

      template {
        data        = <<EOH
          {{ with secret "secrets/data/supysonic"}}
            SUPYSONIC_DB_URI = "postgres://supysonic:{{ .Data.data.db_password}}@db1.ducamps.win/supysonic"
          {{end}}
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
