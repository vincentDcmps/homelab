job "www" {
  datacenters = ["hetzner"]
  type = "service"
  group "www" {
    network {
      mode = "host"
      port "http" {
        to  = 80
        host_network = "private"
      }
    }
    service {
        name = "www"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
       ]
        port = "http"
    }
    task "server" {
      driver = "docker"
      config {
        image = "nginx"
        ports = [
          "http"
        ]
        volumes =[
          "local/nginx.conf:/etc/nginx/nginx.conf",
          "/srv/http:/usr/share/nginx/html"
        ]

      }
    template{
        data= <<EOH
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
  server {
    listen 80;
    root /usr/share/nginx/html;
    error_page 404 /404/404.html;
    error_page   500 502 503 504  /50x.html;
    location / {
      rewrite ^/.well-known/carddav /radicale/$remote_user/carddav/ redirect;
      rewrite ^/.well-known/caldav /radicale/$remote_user/caldav/ redirect;
      index index.html index.htm ;
      default_type text/html;
    }
    location =/ {
      rewrite ^ /welcome;
    }
  }

}
        EOH
        destination="local/nginx.conf"
      }
      resources {
        memory = 50
      }
    }
  }
}
