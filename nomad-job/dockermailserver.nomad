job "dockermailserver" {
  datacenters = ["hetzner"]
  priority    = 90
  type        = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "dockermailserver" {
    network {
      mode = "host"
      port "smtp" {
        to = 25
        static = 25
        host_network = "public"
      }
      port "imap" {
        to = 10993
      }
      port "esmtp" {
        to = 465
      }
    }
    service {
      name = "smtp"
      port = "smtp"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.smtp.service=smtp",
        "traefik.tcp.routers.smtp.entrypoints=smtp",
        "traefik.tcp.routers.smtp.rule=HostSNI(`*`)",
        "traefik.tcp.services.smtp.loadbalancer.proxyProtocol.version=1",
    ]
      check {
        name     = "smtp_probe"
        type     = "tcp"
        interval = "20s"
        timeout  = "2s"
      }
    }
    service {
      name = "esmtp"
      port = "esmtp"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.esmtp.service=esmtp",
        "traefik.tcp.routers.esmtp.entrypoints=esmtp",
        "traefik.tcp.routers.esmtp.rule=HostSNI(`*`)",
        "traefik.tcp.routers.esmtp.tls.passthrough=true",
        "traefik.tcp.services.esmtp.loadbalancer.proxyProtocol.version=1",
      ]
      check {
        name     = "esmtp_probe"
        type     = "tcp"
        interval = "20s"
        timeout  = "2s"
      }
    }
    service {
      name = "imap"
      port = "imap"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.imap.service=imap",
        "traefik.tcp.routers.imap.entrypoints=imap",
        "traefik.tcp.routers.imap.rule=HostSNI(`*`)",
        "traefik.tcp.routers.imap.tls.passthrough=true",
        "traefik.tcp.services.imap.loadbalancer.proxyProtocol.version=2", 
      ]
      check {
        name     = "imap_probe"
        type     = "tcp"
        interval = "20s"
        timeout  = "2s"
      }
    }
    service {
      name = "certmail"
      tags =[
          "traefik.enable=true",
          "traefik.http.routers.certmail.tls.domains[0].sans=mail.ducamps.eu",
          "traefik.http.routers.certmail.tls.certresolver=myresolver",
      ]
    }
    
    #    vault{
    #      policies= ["policy_name"]
    #
    #}
    task "server" {
      driver = "docker"
      config {
        image = "ghcr.io/docker-mailserver/docker-mailserver:edge"
        ports = ["smtp", "esmtp", "imap"]
        volumes = [
          "/mnt/diskstation/nomad/dms/mail-data:/var/mail",
          "/mnt/diskstation/nomad/dms/mail-state:/var/mail-state",
          "/mnt/diskstation/nomad/dms/mail-logs:/var/log/mail",
          "/mnt/diskstation/nomad/dms/config:/tmp/docker-mailserver",
          "/etc/localtime:/etc/localtime",
          "local/postfix-main.cf:/tmp/docker-mailserver/postfix-main.cf",
          "local/postfix-master.cf:/tmp/docker-mailserver/postfix-master.cf",
          "local/dovecot.cf:/tmp/docker-mailserver/dovecot.cf",
          "/mnt/diskstation/nomad/traefik/acme.json:/etc/letsencrypt/acme.json"
        ]
      }

      env {
        OVERRIDE_HOSTNAME = "mail.ducamps.eu"
        DMS_VMAIL_UID = 1000000
        DMS_VMAIL_GID = 100
        SSL_TYPE= "letsencrypt"
        SSL_DOMAIN= "mail.ducamps.eu"
        LOG_LEVEL="info"
      }
      template {
        data        = <<EOH

        EOH
        destination = "secrets/config"
        env         = true
      }

      template {
        data        = <<EOH
#postscreen_upstream_proxy_protocol = haproxy
        EOH
        destination = "local/postfix-main.cf"
      }
      template {
        data        = <<EOH
submission/inet/smtpd_upstream_proxy_protocol=haproxy
submissions/inet/smtpd_upstream_proxy_protocol=haproxy
        EOH
        destination = "local/postfix-master.cf"
      }
      template {
        data        = <<EOH
haproxy_trusted_networks = 10.0.0.0/24, 127.0.0.0/8, 172.17.0.1
haproxy_timeout = 3 secs
service imap-login {
    inet_listener imaps {
    haproxy = yes
    ssl = yes
    port = 10993
  }
}
        EOH
        destination = "local/dovecot.cf"
      }
      resources {
        memory = 300
      }
    }

  }
}
