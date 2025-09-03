
job "nut_exporter" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "0"
  }

  group "nut_exporter"{
    network {
      mode = "host"
      port "http" {
        to = 9199
      }
    }
    service {
      name = "nutexporter"
      port= "http"

      check {
        name= "nut_exporter_probe"
        type= "http"
        path= "/ups_metrics"
        interval = "60s"
        timeout = "2s"
      }
    }
    task "nut_exporter" {
      driver = "docker"
      config {
        image = "ghcr.service.consul:5000/druggeri/nut_exporter:3.2.1"
        ports = ["http"]
      }
      env {
        NUT_EXPORTER_SERVER= "192.168.1.43"
        NUT_EXPORTER_VARIABLES = "battery.runtime,battery.charge,input.voltage,output.voltage,output.voltage.nominal,ups.load,ups.status,ups.realpower"  
      }

      resources {
        memory = 20
      }
    }

  }
}
