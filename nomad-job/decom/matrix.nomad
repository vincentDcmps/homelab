
job "matrix" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "0"
  }

  group "matrix"{
    network {
      mode = "host"
      port "dendrite" {
        to = 8008
      }
      port "element" {
        to = 80
      }
    }
    vault{
      policies= ["dendrite"]

    }
    task "dendrite" {
      driver = "docker"
      service {
        name = "dendrite"
        port = "dendrite"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_TASK_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_TASK_NAME}.tls.domains[0].sans=${NOMAD_TASK_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_TASK_NAME}.tls.certresolver=myresolver",


        ]
      }
      config {
        image = "matrixdotorg/dendrite-monolith"
        ports = ["dendrite"]
        volumes = [
          "local/dendrite.yaml:/etc/dendrite/dendrite.yaml",
          "secrets/matrix_key.pem:/etc/dendrite/matrix_key.pem",
          "/mnt/diskstation/nomad/dendrite/media:/var/dendrite/media"
        ]

      }
      env {
      }

      template {
        data= <<EOH

version: 2

global:
  server_name: dendrite.ducamps.win

  private_key: matrix_key.pem

  old_private_keys:

  key_validity_period: 168h0m0s

  database:

  {{ with secret "secrets/data/database/dendrite"}}
    connection_string: postgresql://dendrite:{{.Data.data.password}}@db1.ducamps.win/dendrite?sslmode=disable
  {{end}}

    max_open_conns: 100
    max_idle_conns: 5
    conn_max_lifetime: -1

  cache:
    max_size_estimated: 1gb

    max_age: 1h

  well_known_server_name: ""

  trusted_third_party_id_servers:
    - matrix.org
    - vector.im

  disable_federation: false

  presence:
    enable_inbound: false
    enable_outbound: false

  report_stats:
    enabled: false
    endpoint: https://matrix.org/report-usage-stats/push

  server_notices:
    enabled: false
    local_part: "_server"
    display_name: "Server Alerts"
    avatar_url: ""
    room_name: "Server Alerts"

  jetstream:
    addresses:

    storage_path: ./

    topic_prefix: Dendrite

  metrics:
    enabled: false
    basic_auth:
      username: metrics
      password: metrics

  dns_cache:
    enabled: false
    cache_size: 256
    cache_lifetime: "5m" # 5 minutes; https://pkg.go.dev/time@master#ParseDuration

app_service_api:
  disable_tls_validation: false

  config_files:

client_api:
  registration_disabled: true

  guests_disabled: true

  registration_shared_secret: ""

  enable_registration_captcha: false

  recaptcha_public_key: ""
  recaptcha_private_key: ""
  recaptcha_bypass_secret: ""
  recaptcha_siteverify_api: ""

  turn:
    turn_user_lifetime: ""
    turn_uris:
    turn_shared_secret: ""
    turn_username: ""
    turn_password: ""

  rate_limiting:
    enabled: true
    threshold: 5
    cooloff_ms: 500
    exempt_user_ids:

federation_api:
  send_max_retries: 16

  disable_tls_validation: false

  key_perspectives:
    - server_name: matrix.org
      keys:
        - key_id: ed25519:auto
          public_key: Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw
        - key_id: ed25519:a_RXGa
          public_key: l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ

  prefer_direct_fetch: false

media_api:
  base_path: ./media_store

  max_file_size_bytes: 10485760

  dynamic_thumbnails: false

  max_thumbnail_generators: 10

  thumbnail_sizes:
    - width: 32
      height: 32
      method: crop
    - width: 96
      height: 96
      method: crop
    - width: 640
      height: 480
      method: scale

mscs:
  mscs:

sync_api:

user_api:
  bcrypt_cost: 10


tracing:
  enabled: false
  jaeger:
    serviceName: ""
    disabled: false
    rpc_metrics: false
    tags: []
    sampler: null
    reporter: null
    headers: null
    baggage_restrictions: null
    throttler: null

logging:
  - type: std
    level: info
  - type: file
    level: info
    params:
      path: ./logs
          EOH
        destination = "local/dendrite.yaml"
      }
template {
  data= <<EOH

{{ with secret "secrets/data/dendrite"}}
{{.Data.data.privateKey}}
{{end}}
          EOH
  destination = "secrets/matrix_key.pem"
      }


      resources {
        memory = 150
      }
    }
    task element {
      driver = "docker"
      service {
        name = "element"
        port = "element"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_TASK_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_TASK_NAME}.tls.domains[0].sans=${NOMAD_TASK_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_TASK_NAME}.tls.certresolver=myresolver",
            "homer.enable=true",
            "homer.name=element",
            "homer.service=Application",
            "homer.logo=https://${NOMAD_TASK_NAME}.ducamps.win",
            "homer.target=_blank",
            "homer.url=https://${NOMAD_TASK_NAME}.ducamps.win",

        ]


      }
      config {
        image = "vectorim/element-web"
        ports = ["element"]
        volumes = ["local/config.json:/app/config.json"]
      }
      template {
        data = <<EOH
{
    "default_server_config": {
        "m.homeserver": {
            "base_url": "https://dendrite.ducamps.win",
            "server_name": "dendrite.ducamps.win"
        },
        "m.identity_server": {
            "base_url": "https://vector.im"
        }
    },
    "disable_custom_urls": false,
    "disable_guests": false,
    "disable_login_language_selector": false,
    "disable_3pid_login": false,
    "brand": "Element",
    "integrations_ui_url": "https://scalar.vector.im/",
    "integrations_rest_url": "https://scalar.vector.im/api",
    "integrations_widgets_urls": [
        "https://scalar.vector.im/_matrix/integrations/v1",
        "https://scalar.vector.im/api",
        "https://scalar-staging.vector.im/_matrix/integrations/v1",
        "https://scalar-staging.vector.im/api",
        "https://scalar-staging.riot.im/scalar/api"
    ],
    "bug_report_endpoint_url": "https://element.io/bugreports/submit",
    "uisi_autorageshake_app": "element-auto-uisi",
    "default_country_code": "GB",
    "show_labs_settings": false,
    "features": { },
    "default_federate": true,
    "default_theme": "dark",
    "room_directory": {
        "servers": [
            "matrix.org"
        ]
    },
    "enable_presence_by_hs_url": {
        "https://matrix.org": false,
        "https://matrix-client.matrix.org": false
    },
    "setting_defaults": {
        "breadcrumbs": true
    },
    "jitsi": {
        "preferred_domain": "meet.element.io"
    },
    "map_style_url": "https://api.maptiler.com/maps/streets/style.json?key=fU3vlMsMn4Jb6dnEIFsx"
}
        EOH
        destination = "local/config.json"

      }
    }

  }
}
