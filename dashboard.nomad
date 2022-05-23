
job "dashboard" {
  datacenters = ["homelab"]
  type = "service"
  meta {
    forcedeploy = "1"
  }

  group "dashboard"{
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
            "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.ducamps.win`)",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.domains[0].sans=${NOMAD_JOB_NAME}.ducamps.win",
            "traefik.http.routers.${NOMAD_JOB_NAME}.tls.certresolver=myresolver",
        ]
      }
      config {
        image = "b4bz/homer"
        ports = ["http"]
        volumes = [
          "/mnt/diskstation/nomad/homer:/www/assets"
        ]

      }
      env {
        INIT_ASSETS= 0
      }

      resources {
        memory = 100
      }
    }
    task "homer-service-discovery" {
      driver = "docker"
      config {
        image= "ducampsv/homer-service-discovery"
        volumes = [
          "/mnt/diskstation/nomad/homer/config.yml:/config.yml",
          "local/base.yml:/base.yml"
        ]
      }
      env {
        SERVICE_DISCOVERY="Consul"
      }

      template{
        data = <<EOH
title: "HomeLab dashboard"
subtitle: "VincentDcmps"
logo: "assets/logo.png"
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
    url: "https://www.ducamps.win/notebook/"
services:
  - name: Application
    icon: "fas fa-heartbeet"
    items: []
  - name: Platform
    icon: "fas fa-code-branch"
    items: []
  - name: Monitoring
    icon: "fab fa-watchman-monitoring"
    items: []

  EOH
        destination = "local/base.yml"

      }
      resources {
        memory= 100
      }
    }

  }
}
