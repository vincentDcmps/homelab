
job "dashboard" {
  datacenters = ["homelab"]
  priority    = 30
  type        = "service"
  meta {
    forcedeploy = "1"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "cluster"
  }
  group "dashboard" {
    network {
      mode = "host"
      port "http" {
        to = 8080
      }
    }

    task "homer" {
      driver = "docker"
      service {
        name = "homer"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.eu`)",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.eu",
          "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
          "traefik.http.routers.${NOMAD_JOB_NAME}.entrypoints=web,websecure",
        ]
      }
      config {
        image = "docker.service.consul:5000/b4bz/homer"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/homer:/www/assets"
        ]

      }
      env {
        INIT_ASSETS = 0
      }

      resources {
        memory = 20
      }
    }
    task "homer-service-discovery" {
      driver = "docker"
      config {
        image = "ducampsv/homer-service-discovery"
        volumes = [
          "/mnt/diskstation/nomad/homer/config.yml:/config.yml",
          "local/base.yml:/base.yml"
        ]
      }
      env {
        SERVICE_DISCOVERY = "Consul"
        CONSUL_HOST       = "consul.service.consul:8500"
      }

      template {
        data        = <<EOH
title: "HomeLab dashboard"
subtitle: "VincentDcmps"
logo: "logo.png"
header: True
footer: "automatic updated by <a href='https://github.com/vincentDcmps/homer-service-discovery'>homer-service-discovery</a>"
columns: "3"
connectivityCheck: true
proxy:
  useCredentials: false
defaults:
  layout: columns
  colorTheme: auto
theme: default
colors:
  light:
    highlight-primary: "#3367d6"
    highlight-secondary: "#4285f4"
    highlight-hover: "#5a95f5"
    background: "#f5f5f5"
    card-background: "#ffffff"
    text: "#363636"
    text-header: "#424242"
    text-title: "#303030"
    text-subtitle: "#424242"
    card-shadow: rgba(0, 0, 0, 0.1)
    link: "#3273dc"
    link-hover: "#363636"
  dark:
    highlight-primary: "#3367d6"
    highlight-secondary: "#4285f4"
    highlight-hover: "#5a95f5"
    background: "#131313"
    card-background: "#2b2b2b"
    text: "#eaeaea"
    text-header: "#ffffff"
    text-title: "#fafafa"
    text-subtitle: "#f5f5f5"
    card-shadow: rgba(0, 0, 0, 0.4)
    link: "#3273dc"
    link-hover: "#ffdd57"

links:
  - name: "github"
    icon: "fab fa-github"
    url: "https://github.com/vincentDcmps/"
    target: "_blank" # optional html tag target attribute
  - name: "notebook"
    icon: "fas fa-book"
    target: "_blank" # optional html tag target attribute
    url: "https://www.ducamps.eu/notebook/"
services:
  - name: Application
    icon: "fas fa-heartbeet"
    items: []
  - name: Platform
    icon: "fas fa-code-branch"
    items:
      - name: Nomad
        logo: https://www.datocms-assets.com/2885/1620155100-brandhcnomadverticalcolor.svg
        url: http://nomad.service.consul:4646
        target: "_blank"
      - name: Consul
        logo: http://consul.service.consul:8500/ui/assets/favicon.svg
        url: http://consul.service.consul:8500
        target: "_blank"
      - name: Vault
        logo: http://active.vault.service.consul:8200/ui/favicon-c02e22ca67f83a0fb6f2fd265074910a.png
        url: http://active.vault.service.consul:8200
        target: "_blank"


  - name: Monitoring
    icon: "fab fa-watchman-monitoring"
    items: []

  EOH
        destination = "local/base.yml"

      }
      resources {
        memory = 30
      }
    }

  }
}
