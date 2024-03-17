
job "MQTT" {
  datacenters = ["homelab"]
  priority    = 90
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "oscar"
  }

  group "MQTT" {
    network {
      mode = "host"
      port "zigbee2mqtt" {
        to = 8090
      }
      port "mosquittoMQTT" {
        static = 1883
        to     = 1883
      }
      port "mosquittoWS" {
        to     = 9001
        static = 9001
      }
    }
    task "mosquitto" {
      driver = "docker"
      service {
        name = "mosquitto"
        port = "mosquittoMQTT"
        tags = [
        ]
      }
      config {
        image = "docker.service.consul:5000/library/eclipse-mosquitto"
        ports = ["mosquittoWS", "mosquittoMQTT"]
        volumes = [
          "/mnt/diskstation/nomad/mosquitto:/mosquitto/data",
          "local/mosquitto.conf:/mosquitto/config/mosquitto.conf"
        ]

      }
      env {
        TZ = "Europe/Paris"
      }
      template {
        data        = <<EOH
persistence false
log_dest stdout
listener 1883
allow_anonymous true
connection_messages true
          EOH
        destination = "local/mosquitto.conf"
      }
      resources {
        memory = 100
      }
    }
    task "Zigbee2MQTT" {
      driver = "docker"
      service {
        name = "Zigbee2MQTT"
        port = "zigbee2mqtt"
        tags = [
          "homer.enable=true",
          "homer.name=zigbee.mqtt",
          "homer.service=Application",
          "homer.logo=https://www.zigbee2mqtt.io/logo.png",
          "homer.target=_blank",
          "homer.url=http://${NOMAD_ADDR_zigbee2mqtt}",

        ]
      }
      config {
        image      = "koenkk/zigbee2mqtt"
        privileged = true
        ports      = ["zigbee2mqtt"]
        volumes = [
          "/mnt/diskstation/nomad/zigbee2mqtt:/app/data",
          "local/configuration.yaml:/app/data/configuration.yaml",
          "/run/udev:/run/udev",
          "/dev/ttyACM0:/dev/ttyACM0",
        ]

      }
      env {
        TZ = "Europe/Paris"
      }

      template {
        data        = <<EOH
# MQTT settings
mqtt:
  # MQTT base topic for Zigbee2MQTT MQTT messages
  base_topic: zigbee2mqtt
  # MQTT server URL
  server: 'mqtt://{{env "NOMAD_ADDR_mosquittoMQTT"}}'
  # MQTT server authentication, uncomment if required:
  # user: my_user
  # password: my_password
frontend:
  port: 8090
homeassistant: true
devices:
  '0x00158d00027bf710':
    friendly_name: remote_chambre
  '0x00158d0003fabc52':
    friendly_name: weather_chambre
  '0x00158d0003cd381c':
    friendly_name: weather_exterieur
  '0x00158d00036d5fe8':
    friendly_name:  motion_sensor_chambre



# Serial settings
serial:
  # Location of the adapter (see first step of this guide)
  adapter: deconz
  port: /dev/ttyACM0
          EOH
        destination = "local/configuration.yaml"
      }
      resources {
        memory = 175
      }
    }
  }
}
