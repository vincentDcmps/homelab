
job "prestashop" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  group "prestashop"{
    network {
      mode = "host"
      port "http" {
      to = 80
      }
      port "mysql" {
        to = 3306
        static=23306
      }
    }
    volume "prestashop-data" {
      type            = "csi"
      source          = "prestashop-data"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    volume "prestashop-sql" {
      type            = "csi"
      source          = "prestashop-sql"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    vault{
    }
    task "mysql" {
      driver = "docker"
      service {
        name = "prestashop-sql"
        port = "mysql"
        tags = [
        ]
      }
      lifecycle {
        hook    = "prestart"
        sidecar = true
      }
      volume_mount {
        volume      = "prestashop-sql"
        destination = "/var/lib/mysql"
      }
      config {
        image = "mysql:8.0"
        ports = ["mysql"]
        
      }
      env {
          MYSQL_DATABASE= "prestashop"
      }
      template {
        data= <<EOH
          {{ with secret "secrets/data/nomad/prestashop"}}
            MYSQL_ROOT_PASSWORD= {{ .Data.data.MYSQL_ROOT_PASSWORD }}
          {{end}}
          EOH
        destination = "secrets/mysql.env"
        env = true
      }
      resources {
        memory = 700
      }
    }
    task "prestashop" {
      driver = "docker"
      service {
        name = "prestashop"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
            "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
        ]
      }
      volume_mount {
        volume      = "prestashop-data"
        destination = "/var/www/html"
      }
      config {
        image = "docker.service.consul:5000/prestashop/prestashop:8.2.1-apache"
        ports = ["http"]
      }
      env {
        PS_DEV_MODE = 1
        PS_INSTALL_AUTO=0
        DB_SERVER= "prestashop-sql.service.consul"
        DB_PORT= "${NOMAD_HOST_PORT_mysql}"
        DB_NAME= "prestashop"
        PS_HANDLE_DYNAMIC_DOMAIN=1
        PS_ENABLE_SSL=1
        PS_TRUSTED_PROXIES= "192.168.1.0/24,10.0.0.4"
        PS_DOMAIN = "prestashop.ducamps.eu"
        PS_COUNTRY = "fr"
        PS_LANGUAGE = "fr"
       }
      template {
        data= <<EOH
        {{ with secret "secrets/data/nomad/prestashop"}}
           DB_PASSWD= {{ .Data.data.MYSQL_ROOT_PASSWORD }}
           ADMIN_MAIL= vincent@ducamps.eu
           ADMIN_PASSWD= {{ .Data.data.admin }}
          {{end}}
          EOH
        destination = "secrets/prestashop.env"
        env = true
      }
      resources {
        memory = 500
      }
    }

  }
}
