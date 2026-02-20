
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
        image = "authelia/authelia:4.39.15"
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
    cors:
      endpoints:
        - userinfo
        - authorization
        - token
        - revocation
        - introspection
      allowed_origins: 
        - https://mealie.ducamps.eu
      allowed_origins_from_client_redirect_uris: true
    clients:
      - client_id: 'actual-budget'
        client_name: 'Actual Budget'
        client_secret: {{ with secret "secrets/data/authelia/actualbudget"}} {{ .Data.data.hash }} {{end}}
        public: false
        authorization_policy: 'one_factor'
        require_pkce: false
        pkce_challenge_method: ''
        redirect_uris:
          - 'https://budget.ducamps.eu/openid/callback'
        scopes:
          - 'openid'
          - 'profile'
          - 'groups'
          - 'email'
        response_types:
          - 'code'
        grant_types:
          - 'authorization_code'
        access_token_signed_response_alg: 'none'
        userinfo_signed_response_alg: 'none'
        token_endpoint_auth_method: 'client_secret_basic'
        pre_configured_consent_duration: 6M
      - client_id: 'ttrss'
        client_name: 'ttrss'
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
        pre_configured_consent_duration: 6M
      - client_id: 'mealie'
        client_name: 'mealie'
        client_secret: {{ with secret "secrets/data/authelia/mealie"}} {{ .Data.data.hash }} {{end}}
        public: false
        require_pkce: true
        pkce_challenge_method: 'S256'
        scopes:
          - openid
          - email
          - profile
          - groups
        redirect_uris:
          - 'https://mealie.ducamps.eu/login'
        userinfo_signed_response_alg: none
        authorization_policy: 'one_factor'
        pre_configured_consent_duration: 6M
      - client_id: 'immich'
        client_name: 'immich'
        client_secret: {{ with secret "secrets/data/authelia/immich"}} {{ .Data.data.hash }} {{end}}
        public: false
        authorization_policy: 'one_factor'
        redirect_uris:
          - 'https://immich.ducamps.eu/auth/login'
          - 'https://immich.ducamps.eu/user-settings'
          - 'app.immich:/'
        scopes:
          - 'openid'
          - 'profile'
          - 'email'
        userinfo_signed_response_alg: 'none'
        pre_configured_consent_duration: 6M
        token_endpoint_auth_method: "client_secret_post"
      - client_id: 'grafana'
        client_name: 'Grafana'
        client_secret:{{ with secret "secrets/data/authelia/grafana"}} {{ .Data.data.hash }} {{end}}
        public: false
        authorization_policy: 'one_factor'
        require_pkce: true
        pkce_challenge_method: 'S256'
        redirect_uris:
          - 'https://grafana.ducamps.eu/login/generic_oauth'
        scopes:
          - 'openid'
          - 'profile'
          - 'groups'
          - 'email'
        userinfo_signed_response_alg: 'none'
        token_endpoint_auth_method: 'client_secret_basic'
        pre_configured_consent_duration: 6M
      - client_id: 'vikunja'
        client_name: 'vikunja'
        client_secret:{{ with secret "secrets/data/authelia/vikunja"}} {{ .Data.data.hash }} {{end}}
        public: false
        authorization_policy: 'one_factor'
        redirect_uris:
          - 'https://vikunja.ducamps.eu/auth/openid/authelia'
        scopes:
          - 'openid'
          - 'profile'
          - 'email'
        userinfo_signed_response_alg: 'none'
        token_endpoint_auth_method: 'client_secret_basic' 
        pre_configured_consent_duration: 6M
      - client_id: 'gitea'
        client_name: 'gitea'
        client_secret:{{ with secret "secrets/data/authelia/gitea"}} {{ .Data.data.hash }} {{end}}
        public: false
        authorization_policy: 'one_factor'
        redirect_uris:
          - 'https://git.ducamps.eu/user/oauth2/authelia/callback'
        scopes:
          - 'openid'
          - 'profile'
          - 'email'
        userinfo_signed_response_alg: 'none'
        token_endpoint_auth_method: 'client_secret_basic'
        pre_configured_consent_duration: 6M
      - client_id: 'miniflux'
        client_name: 'Miniflux'
        client_secret: {{ with secret "secrets/data/authelia/miniflux"}} {{ .Data.data.hash }} {{end}}
        public: false
        authorization_policy: 'one_factor'
        require_pkce: false
        pkce_challenge_method: ''
        redirect_uris:
          - 'https://rss.ducamps.eu/oauth2/oidc/callback'
        scopes:
          - 'openid'
          - 'profile'
          - 'email'
        response_types:
          - 'code'
        grant_types:
          - 'authorization_code'
        access_token_signed_response_alg: 'none'
        userinfo_signed_response_alg: 'none'
        token_endpoint_auth_method: 'client_secret_basic'
        pre_configured_consent_duration: 6M
      - client_id: 'filebrowser'
        client_name: 'FileBrowser Quantum'
        client_secret: {{ with secret "secrets/data/authelia/filebrowser"}} {{ .Data.data.hash }} {{end}}
        public: false
        authorization_policy: 'one_factor'
        require_pkce: false
        pkce_challenge_method: ''
        redirect_uris:
          - 'https://file.ducamps.eu/api/auth/oidc/callback'
        scopes:
          - 'openid'
          - 'profile'
          - 'groups'
          - 'email'
        response_types:
          - 'code'
        grant_types:
          - 'authorization_code'
        access_token_signed_response_alg: 'none'
        userinfo_signed_response_alg: 'none'
        token_endpoint_auth_method: 'client_secret_basic'
        pre_configured_consent_duration: 6M

identity_validation:
  reset_password:
    jwt_secret: '{{ with secret "secrets/data/nomad/authelia"}} {{ .Data.data.resetPassword }} {{end}}'
log:
  level: 'trace'

totp:
  issuer: 'authelia.com'


authentication_backend:
  ldap:
    address: 'ldaps://ldap.service.consul'
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
    #groups_filter: '(&(member=UID={input},OU=users,DC=ducamps,DC=eu)(objectClass=groupOfNames))'
    groups_filter: '(&(|{memberof:rdn})(objectClass=groupOfNames))'
    group_search_mode: 'memberof'
    user: 'uid=autheliaServiceAccount,ou=serviceAccount,ou=users,dc=ducamps,dc=eu'
    password:{{ with secret "secrets/data/nomad/authelia"}} '{{ .Data.data.ldapPassword }}'{{ end }}
    attributes:
      distinguished_name: ''
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
  disable_startup_check: true
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
