
job "nextcloud" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }

  group "nextcloud"{
    network {
      mode = "host"
      port "http" {
        to = 80
      }
    }
    vault{
      policies= ["access-table"]

    }
    task "server" {
      driver = "docker"
      service {
        name = "nextcloud"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`file.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=file.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "nextcloud:latest"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nextcloud:/data"
          "local/default:/config/nginx/site-confs/default"
        ]

      }
      env {
      }

      template {
        data= <<EOH
          {{ with secret "secrets/data/sample"}}
          POSTGRES_DB="nextcloud"
          POSTGRES_USER="{{.Data.data.user}}"
          POSTGRES_PASSWORD=""
          NEXTCLOUD_ADMIN_USER=""
          NEXTCLOUD_ADMIN_PASSWORD=""
          NEXTCLOUD_TRUSTED_DOMAINS="file.ducamps.win"
          POSTGRES_HOST=""
          {{end}}
          EOH
        destination = "secrets/sample.env"
        env = true
      }

         template {
data = <<EOH
upstream php-handler {
    server 127.0.0.1:9000;
}
#server {
#    listen 80;
#    listen [::]:80;
#    server_name _;
#    return 301 https://$host$request_uri;
#}
server {
    listen 80;
    listen [::]:80;
    server_name _;
    ssl_certificate /config/keys/cert.crt;
    ssl_certificate_key /config/keys/cert.key;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header X-Download-Options noopen;
    add_header X-Permitted-Cross-Domain-Policies none;
    add_header Referrer-Policy no-referrer;
    fastcgi_hide_header X-Powered-By;
    root /config/www/nextcloud/;
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    location = /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }
    location = /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
    client_max_body_size 10G;
    fastcgi_buffers 64 4K;
    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
    gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
    location / {
        rewrite ^ /index.php;
    }
    location ~ ^\/(?:build|tests|config|lib|3rdparty|templates|data)\/ {
        deny all;
    }
    location ~ ^\/(?:\.|autotest|occ|issue|indie|db_|console) {
        deny all;
    }
    location ~ ^\/(?:index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|ocs-provider\/.+|ocm-provider\/.+)\.php(?:$|\/) {
        fastcgi_split_path_info ^(.+?\.php)(\/.*|)$;
        try_files $fastcgi_script_name =404;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTPS on;
        fastcgi_param modHeadersAvailable true;
        fastcgi_param front_controller_active true;
        fastcgi_pass php-handler;
        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
    }

    location ~ ^\/(?:updater|ocs-provider|ocm-provider)(?:$|\/) {
        try_files $uri/ =404;
        index index.php;
    }
    location ~ \.(?:css|js|woff2?|svg|gif)$ {
        try_files $uri /index.php$request_uri;
        add_header Cache-Control "public, max-age=15778463";
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        add_header Referrer-Policy no-referrer;
        access_log off;
    }
    location ~ \.(?:png|html|ttf|ico|jpg|jpeg)$ {
        try_files $uri /index.php$request_uri;
        access_log off;
    }
}
EOH
        destination = "local/default"
        env         = false
      }

    }

  }
}
