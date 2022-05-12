job "tt-rss" {
  datacenters = ["homelab"]
  type = "service"


  group "tt-rss" {
    ephemeral_disk {
      migrate = true
      size    =  200
      sticky  = true
    }
    network {
      mode = "host"
      port "http"{
        to = 80
      }
      port "appPort" {
        to = 9000
      }
    }
    vault {
      policies = ["access-tables"]
    }
    service {
      name = "tt-rss"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`www.ducamps.win`)&&PathPrefix(`/tt-rss`)",
        "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=www.ducamps.win",
        "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
      ]
    }


    task "ttrss-app" {
      driver = "docker"
      config {
        image = "cthulhoo/ttrss-fpm-pgsql-static"
        ports = [
         "appPort"
        ]
        volumes = [
          "${NOMAD_ALLOC_DIR}/data:/var/www/html"
        ]
      }
      env {
        TTRSS_DB-TYPE = "pgsql"
        TTRSS_DB_HOST = "db1.ducamps.win"
        TTRSS_DB_NAME = "ttrss"
        TTRSS_DB_USER = "ttrss"
        TTRSS_SELF_URL_PATH = "https://www.ducamps.win/tt-rss"
      }
      template {
        data= <<EOH
            {{ with secret "secrets/data/ttrss"}}
            TTRSS_DB_PASS = "{{ .Data.data.DB_PASS }}"
            {{end}}
          EOH
        destination = "secrets/tt-rss.env"
        env = true

      }
      resources {
        memory = 150
      }
    }

   task "ttrss-updater" {
      driver = "docker"
      config {
        image = "cthulhoo/ttrss-fpm-pgsql-static"
        volumes = [
          "${NOMAD_ALLOC_DIR}/data:/var/www/html"
        ]
        command = "/opt/tt-rss/updater.sh"

      }
      env {
        TTRSS_DB-TYPE = "pgsql"
        TTRSS_DB_HOST = "db1.ducamps.win"
        TTRSS_DB_NAME = "ttrss"
        TTRSS_DB_USER = "ttrss"
        TTRSS_SELF_URL_PATH = "https://rss.ducamps.win/tt-rss"
      }
      template {
        data= <<EOH
            {{ with secret "secrets/data/ttrss"}}
            TTRSS_DB_PASS = "{{ .Data.data.DB_PASS }}"
            {{end}}
          EOH
        destination = "secrets/tt-rss.env"
        env = true

      }
      resources {
        memory = 150
      }
    }

    task "ttrss-frontend" {
      driver = "docker"
      config {
        image= "nginx:alpine"
        ports= [
          "http"
        ]
        volumes = [
          "etc/nginx/nginx.conf:/etc/nginx/nginx.conf",
          "${NOMAD_ALLOC_DIR}/data:/var/www/html"
        ]
      }

      template {
        data = <<EOH
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
        memory = 50
      }
    }

  }
}
