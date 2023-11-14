
job "lldap" {
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

  group "lldap"{
    network {
      mode = "host"
      port "ldap" {
        to = 3890
        static = 3890
      }
      port "http" {
        to = 17170
      }
    }
#    vault{
#      policies= ["lldap"]
#
#    }
    service {
      name = "lldapHttp"
      port = "http"
      tags = [
      ]
    }
    service {
      name = "lldapLDAP"
      port = "ldap"
      tags = [
      ]
    }
    task "lldap" {
      driver = "docker"
      config {
        image = "lldap/lldap:latest"
        ports = ["ldap","http"]
        volumes = [
          "/mnt/diskstation/nomad/lldap:/data"
        ]
      }

      template {
        data= <<EOH
            UID=1000000
            LLDAP_JWT_SECRET=
            LLDAP_LDAP_USER_PASS=REPLACE_WITH_PASSWORD
            LLDAP_LDAP_BASE_DN=dc=ducamps,dc=eu

        EOH
        destination = "secrets/env"
        env = true
      }
      resources {
        memory = 300
      }
    }

  }
}
