job "tt-rss" {
  datacenters = ["homelab"]
  priority    = 90
  type        = "service"

  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }

  group "ttrss" {
    ephemeral_disk {
      migrate = true
      size    = 200
      sticky  = true
    }
    network {
      mode = "host"
      port "http" {
        to = 80
      }
      port "appPort" {
        to = 9000
      }
    }
    vault {
      policies = ["ttrss"]
    }
    service {
      name = "tt-rss"
      port = "http"
      tags = [
        "homer.enable=true",
        "homer.name=TT-RSS",
        "homer.service=Application",
        "homer.logo=https://www.ducamps.eu/tt-rss/images/favicon-72px.png",
        "homer.target=_blank",
        "homer.url=https://www.ducamps.eu/tt-rss",

        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`www.ducamps.eu`)&&PathPrefix(`/tt-rss`)",
        "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=www.ducamps.eu",
        "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
        "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
      ]
    }


    task "ttrss-app" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/cthulhoo/ttrss-fpm-pgsql-static"
        ports = [
          "appPort"
        ]
        volumes = [
          "${NOMAD_ALLOC_DIR}/data:/var/www/html",
          "/mnt/diskstation/nomad/tt-rss/ttrss-auth-oidc:/var/www/html/tt-rss/plugins.local/auth_oidc"
        ]
      }
      env {
        TTRSS_DB-TYPE       = "pgsql"
        TTRSS_DB_HOST       = "active.db.service.consul"
        TTRSS_DB_NAME       = "ttrss"
        TTRSS_DB_USER       = "ttrss"
        TTRSS_SELF_URL_PATH = "https://www.ducamps.eu/tt-rss"
        TTRSS_PLUGINS       = "auth_oidc, auth_internal"
        TTRSS_AUTH_OIDC_NAME= "Authelia"
        TTRSS_AUTH_OIDC_URL = "https://auth.ducamps.eu"
        TTRSS_AUTH_OIDC_CLIENT_ID = "ttrss"
      }
      template {
        data        = <<EOH
            {{ with secret "secrets/data/database/ttrss"}}TTRSS_DB_PASS = "{{ .Data.data.password }}"{{end}} 
            TTRSS_AUTH_OIDC_CLIENT_SECRET = {{ with secret "secrets/data/authelia/ttrss"}}"{{ .Data.data.password }}"{{end}}
          EOH
        destination = "secret/tt-rss.env"
        env         = true
      }
      resources {
        cpu = 50
        memory = 150
      }
    }

    task "ttrss-updater" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/cthulhoo/ttrss-fpm-pgsql-static"
        volumes = [
          "${NOMAD_ALLOC_DIR}/data:/var/www/html"
        ]
        command = "/opt/tt-rss/updater.sh"

      }
      env {
        TTRSS_DB-TYPE       = "pgsql"
        TTRSS_DB_HOST       = "active.db.service.consul"
        TTRSS_DB_NAME       = "ttrss"
        TTRSS_DB_USER       = "ttrss"
        TTRSS_SELF_URL_PATH = "https://www.ducamps.eu/tt-rss"
      }
      template {
        data        = <<EOH
            {{ with secret "secrets/data/database/ttrss"}}
            TTRSS_DB_PASS = "{{ .Data.data.password }}"
            {{end}}
          EOH
        destination = "secrets/tt-rss.env"
        env         = true

      }
      resources {
        cpu = 50
        memory = 150
      }
    }

    task "ttrss-frontend" {
      driver = "docker"
      config {
        image = "docker.service.consul:5000/library/nginx:alpine"
        ports = [
          "http"
        ]
        volumes = [
          "etc/nginx/nginx.conf:/etc/nginx/nginx.conf",
          "${NOMAD_ALLOC_DIR}/data:/var/www/html"
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
              	include /etc/nginx/mime.types;
              	default_type  application/octet-stream;

              	access_log /dev/stdout;
              	error_log /dev/stderr warn;

              	sendfile on;

              	index index.php;

              	upstream app {
              		server {{ env "NOMAD_ADDR_appPort" }};
              	}

              	server {
              		listen 80;
              		listen [::]:80;
              		root /var/www/html;

              		location /tt-rss/cache {
              			aio threads;
              			internal;
              		}

              		location /tt-rss/backups {
              			internal;
              		}

              		location ~ \.php$ {
              			# regex to split $uri to $fastcgi_script_name and $fastcgi_path
              			fastcgi_split_path_info ^(.+?\.php)(/.*)$;

              			# Check that the PHP script exists before passing it
              			try_files $fastcgi_script_name =404;

              			# Bypass the fact that try_files resets $fastcgi_path_info
              			# see: http://trac.nginx.org/nginx/ticket/321
              			set $path_info $fastcgi_path_info;
              			fastcgi_param PATH_INFO $path_info;

              			fastcgi_index index.php;
              			include fastcgi.conf;

              			fastcgi_pass app;
              		}

              		location / {
              			try_files $uri $uri/ =404;
              		}

              	}
              }
          EOH
        destination = "etc/nginx/nginx.conf"
      }

      resources {
        cpu = 50
        memory = 50
      }
    }

  }
}
