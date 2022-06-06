
job "rsyncd" {
  datacenters = ["hetzner"]
  type = "service"
  meta {
    forcedeploy = "1"
  }

  vault {
    policies = ["access-tables"] 
  }

  group "rsyncd"{
    network {
      mode = "host"
      port "rsync" {
        static = 873
      }
    }
    task "server" {
      driver = "docker"
      config {
        image = "vimagick/rsyncd"
        ports = ["rsync"]
        volumes = [
          "/mnt/hetzner/storagebox/:/share",
          "local/rsyncd.conf:/etc/rsyncd.conf",
          "secrets/rsyncd.secrets:/etc/rsyncd.secrets"
          
        ]

      }

      template {
        data= <<EOH
[global]
uid = root
guid = root
charset = utf-8
max connections = 8
reverse lookup = no

[storagebox]
path = /share
read only = no
#hosts allow = 192.168.1.0/24
auth users = *
secrets file = /etc/rsyncd.secrets
open noatim
#strict modes = false
          EOH
        destination = "local/rsyncd.conf"
      }
      template {
        data= <<EOH
{{ with secret "secrets/data/rsyncd"}}
{{.Data.data.user}}:{{.Data.data.pass}}
{{end}}
EOH
        destination = "secrets/rsyncd.secrets"
        perms = 400
      }
      resources {
        memory = 300
      }
    }

  }
}
