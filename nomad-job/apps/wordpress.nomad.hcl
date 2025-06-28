
job "wordpress" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "1"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  group "wordpress"{
    network {
      mode = "host"
      port "http" {
      to = 80
      }
      port "mysql" {
        to = 3306
        static=33306
      }
    }
    volume "wordpress-data" {
      type            = "csi"
      source          = "wordpress-data"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    volume "wordpress-sql" {
      type            = "csi"
      source          = "wordpress-sql"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    vault{
    }
    task "mysql" {
      driver = "docker"
      service {
        name = "wordpress-sql"
        port = "mysql"
        tags = [
        ]
      }
      lifecycle {
        hook    = "prestart"
        sidecar = true
      }
      volume_mount {
        volume      = "wordpress-sql"
        destination = "/var/lib/mysql"
      }
      config {
        image = "mysql:8.0"
        ports = ["mysql"]
        
      }
      env {
          MYSQL_DATABASE= "wordpress"
      }
      template {
        data= <<EOH
          {{ with secret "secrets/data/nomad/wordpress"}}
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
    task "wordpress" {
      driver = "docker"
      service {
        name = "wordpress"
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
        volume      = "wordpress-data"
        destination = "/var/www/html"
      }
      config {
        image = "docker.service.consul:5000/library/wordpress:6.8.1"
        ports = ["http"]
      }
      env {
        PS_DEV_MODE = 1
        PS_INSTALL_AUTO=0
        WORDPRESS_DB_HOST= "wordpress-sql.service.consul:${NOMAD_HOST_PORT_mysql}"
        WORDPRESS_DB_NAME= "wordpress"
        WORDPRESS_DB_USER = "root"
       }
      template {
        data= <<EOH
        {{ with secret "secrets/data/nomad/wordpress"}}
           WORDPRESS_DB_PASSWORD= {{ .Data.data.MYSQL_ROOT_PASSWORD }}
          {{end}}
          EOH
        destination = "secrets/wordpress.env"
        env = true
      }
      resources {
        memory = 500
      }
    }

  }
}
