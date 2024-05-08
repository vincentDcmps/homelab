
job "openldap" {
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
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }

  vault {
    policies = ["ldap"]
  }
  group "openldap" {
    network {
      mode = "host"
      port "ldap" {
        static = 389
        to     = 1389
      }
      port "ldaps" {
        static = 636
        to     = 1636
      }

    }
    task "selfsignedCertificate" {
      lifecycle {
        hook= "prestart"
        sidecar = false
      }
      driver= "docker"
      config{
        image= "stakater/ssl-certs-generator"
        mount {
          type = "bind"
          source = "..${NOMAD_ALLOC_DIR}/data"
          target = "/certs"
        }
      }
      env {
        SSL_DNS="ldaps.service.consul,ldap.service.consul"
      }
    }
    task "openldap" {
      driver = "docker"
      service {
        name = "ldap"
        port = "ldap"
        tags = [
        ]
      }
      service {
        name = "ldaps"
        port = "ldaps"
        tags = [
        ]
      }

      config {
        image = "bitnami/openldap"
        ports = ["ldap", "ldaps"]
        volumes = [
          "/mnt/diskstation/nomad/openldap:/bitnami/openldap",
        ]

      }
      env {
        LDAP_ADMIN_USERNAME     = "admin"
        LDAP_ROOT               = "dc=ducamps,dc=eu"
        LDAP_EXTRA_SCHEMAS      = "cosine, inetorgperson"
        LDAP_CUSTOM_SCHEMA_DIR  = "/local/schema"
        LDAP_CUSTOM_LDIF_DIR    = "/local/ldif"
        LDAP_CONFIGURE_PPOLICY  = "yes"
        LDAP_ALLOW_ANON_BINDING = "no"
        LDAP_LOGLEVEL           = 64
        LDAP_ENABLE_TLS         = "yes"
        LDAP_TLS_CERT_FILE = "${NOMAD_ALLOC_DIR}/data/cert.pem"
        LDAP_TLS_KEY_FILE = "${NOMAD_ALLOC_DIR}/data/key.pem"
        LDAP_TLS_CA_FILE = "${NOMAD_ALLOC_DIR}/data/ca.pem"

      }

      template {
        data = <<EOH
          {{ with secret "secrets/data/nomad/ldap"}}
          LDAP_ADMIN_PASSWORD="{{ .Data.data.admin}}"
          {{end}}
        EOH
        env=true
        destination= "secrets/env"
      }
      #memberOf issue
      #https://github.com/bitnami/containers/issues/28335
      # https://tylersguides.com/guides/openldap-memberof-overlay


      template {
        data        = file("memberofOverlay.ldif")
        destination = "local/schema/memberofOverlay.ldif"
      }
      template {
        data        = file("smbkrb5pwd.ldif")
        destination = "local/smbkrb5pwd.ldif"
      }
      template {
        data        = file("rfc2307bis.ldif")
        destination = "local/schema/rfc2307bis.ldif"
      }
      template {
        data        = file("samba.ldif")
        destination = "local/schema/samba.ldif"
      }
      template {
        data        = file("tree.ldif")
        destination = "local/ldif/tree.ldif"
      }
      resources {
        memory = 300
      }
    }
  }
  group ldpp-user-manager{ 
    network{
      mode = "host"
      port "http" {
        to = 80
      }
    }
    task ldap-user-manager {
      driver = "docker"
      service {
        name = "ldap-user-manager"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`ldap.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=ldap.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
        ]
      }
      config {
        image = "wheelybird/ldap-user-manager"
        ports = ["http"]
      }
      template {
        data        = <<EOH
          SERVER_HOSTNAME="ldap.ducamps.eu"
          LDAP_URI="ldaps://ldaps.service.consul"
          LDAP_BASE_DN="dc=ducamps,dc=eu"
          LDAP_ADMIN_BIND_DN="cn=admin,dc=ducamps,dc=eu"
          LDAP_GROUP_MEMBERSHIP_ATTRIBUTE = "member"
          {{ with secret "secrets/data/nomad/ldap"}}
          LDAP_ADMIN_BIND_PWD="{{ .Data.data.admin}}"
          {{end}}
          LDAP_IGNORE_CERT_ERRORS="true"
          LDAP_REQUIRE_STARTTLS="false"
          LDAP_ADMINS_GROUP="LDAP Operators"
          LDAP_USER_OU="users"
          NO_HTTPS="true"
          EMAIL_DOMAIN="ducamps.eu"
          DEFAULT_USER_GROUP="users"
          DEFAULT_USER_SHELL="/bin/sh"
          USERNAME_FORMAT="{first_name}"
          LDAP_RFC2307BIS_SCHEMA="TRUE"
          USERNAME_REGEX="^[a-zA-Z][a-zA-Z0-9._-]{3,32}$"
          LDAP_GROUP_ADDITIONAL_OBJECTCLASSES="groupOfNames,posixGroup,top"
          SHOW_POSIX_ATTRIBUTES="TRUE"

        EOH
        destination = "secrets/env"
        env         = true
      }
    }
  }

}


