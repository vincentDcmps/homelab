
job "authelia" {
  datacenters = ["homelab"]
  priority    = 80
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "authelia" {
    network {
      mode = "host"
      port "authelia" {
        to = 9091
      }
    }
    volume "authelia-config" {
      type            = "csi"
      source          = "authelia-config"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    vault {
      policies = ["authelia"]

    }
    task "authelia" {
      driver = "docker"
      service {
        name = "authelia"
        port = "authelia"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`auth.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=auth.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",


        ]
      }
      config {
        image = "authelia/authelia"
        ports = ["authelia"]
        args = [
          "--config",
          "/local/configuration.yml",
        ]


      }
      volume_mount {
          volume      = "authelia-config"
          destination = "/config"
      }
      env {
        AUTHELIA_SESSION_SECRET = uuidv4()
        AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET = uuidv4()
      }

      template {
        data        = <<EOH

---
###############################################################
#                   Authelia configuration                    #
###############################################################

server:
  address: 'tcp://:9091'
  endpoints:
    authz:
      forward-auth:
        implementation: 'ForwardAuth'
      legacy:
        implementation: 'Legacy'

log:
  level: 'debug'

totp:
  issuer: 'authelia.com'


{{ with secret "secrets/data/nomad/authelia"}}
authentication_backend:
  ldap:
    address: 'ldaps://ldap.ducamps.eu'
    implementation: 'custom'
    timeout: '5s'
    start_tls: false
    tls:
      skip_verify: true
      minimum_version: 'TLS1.2'
    base_dn: 'DC=ducamps,DC=eu'
    additional_users_dn: 'OU=users'
    users_filter: '(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))'
    additional_groups_dn: 'OU=groups'
    groups_filter: '(&(member=UID={input},OU=users,DC=ducamps,DC=eu)(objectClass=groupOfNames))'
    user: 'uid=authelia,ou=serviceAccount,ou=users,dc=ducamps,dc=eu'
    password: '{{ .Data.data.ldapPassword }}'
    attributes:
      distinguished_name: 'distinguishedname'
      username: 'uid'
      mail: 'mail'
      member_of: 'memberOf'
      group_name: 'cn'

access_control:
  default_policy: 'deny'
  rules:
    # Rules applied to everyone
    - domain: '*.ducamps.eu'
      policy: 'one_factor'

session:
  cookies:
    - name: 'authelia_session'
      domain: 'ducamps.eu'  # Should match whatever your root protected domain is
      authelia_url: 'https://auth.ducamps.eu'
      expiration: '1 hour'
      inactivity: '5 minutes'


regulation:
  max_retries: 3
  find_time: '2 minutes'
  ban_time: '5 minutes'

storage:
  encryption_key: '{{.Data.data.encryptionKeys }}'
  local:
    path: '/config/db.sqlite3'

notifier:
  smtp:
    username: 'authelia@ducamps.eu'
#    # This secret can also be set using the env variables AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE
    password: '{{ .Data.data.mailPassword}}'
    host: 'mail.ducamps.eu'
    port: 465
    disable_require_tls: true
    sender: 'authelia@ducamps.eu'
    tls:
      server_name: 'mail.ducamps.eu'
      skip_verify: true
{{end}}
          EOH
        destination = "local/configuration.yml"
      }
      resources {
        memory = 100
      }
    }

  }
}
