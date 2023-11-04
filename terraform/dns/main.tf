terraform {
  backend "consul" {
    path  = "terraform/dns"
  }
  required_providers {
    powerdns = {
      source = "pan-net/powerdns"
    }   
    hetznerdns = {
      source="timohirt/hetznerdns"
    }
  }
}
provider vault {
}

provider "powerdns" {
  api_key    = var.powerDnsApiKey
  server_url = var.powerDnsURL
}

provider "hetznerdns" {
    apitoken = var.hetznerApiKey
}

