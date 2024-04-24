
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
      action "generate-client-secret" {
        command = "authelia"
        args = ["crypto",
                "hash",
                "generate",
                "pbkdf2",
                "--random",
                "--random.length",
                "72",
                "--random.charset",
                "rfc3986"
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

identity_providers:
  oidc:
    hmac_secret: {{ with secret "secrets/data/nomad/authelia"}}{{ .Data.data.hmac}}{{end}}
    jwks:
     - key_id: 'key'
       key: |
{{ with secret "secrets/data/nomad/authelia"}}{{ .Data.data.rsakey|indent 8 }}{{end}}
    clients:
      - client_id: 'ttrss'
        client_name: 'ttrss'
#        client_secret: $pbkdf2-sha512$310000$5igZ9BADDMeXml91wcIq3w$fNFeVMHDxXx758cYQe0kmgidZMedEgtN.zQd12xE9DzmSk8QRRUYx56zpjzLTO8PcKhDgR3qCdUPnO/XDdEDLg
        client_secret: {{ with secret "secrets/data/authelia/ttrss"}} {{ .Data.data.hash }} {{end}}
        public: false
        scopes:
          - openid
          - email
          - profile
        redirect_uris:
          - 'https://www.ducamps.eu/tt-rss'
        userinfo_signed_response_alg: none
        authorization_policy: 'one_factor'
        pre_configured_consent_duration: 15d

log:
  level: 'debug'

totp:
  issuer: 'authelia.com'


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
    password:{{ with secret "secrets/data/nomad/authelia"}} '{{ .Data.data.ldapPassword }}'{{ end }}
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
      expiration: '12 hour'
      inactivity: '5 minutes'


regulation:
  max_retries: 3
  find_time: '2 minutes'
  ban_time: '5 minutes'

storage:
{{ with secret "secrets/data/nomad/authelia"}}
  encryption_key: '{{.Data.data.encryptionKeys }}'
{{end}}
  local:
    path: '/config/db.sqlite3'

notifier:
  smtp:
    username: 'authelia@ducamps.eu'
{{ with secret "secrets/data/nomad/authelia"}}
    password: '{{ .Data.data.mailPassword}}'
{{end}}
    address: submissions://mail.ducamps.eu:465
    disable_require_tls: true
    sender: 'authelia@ducamps.eu'
    tls:
      server_name: 'mail.ducamps.eu'
      skip_verify: true
          EOH
        destination = "local/configuration.yml"
      }
      resources {
        memory = 100
      }
    }

  }
}
