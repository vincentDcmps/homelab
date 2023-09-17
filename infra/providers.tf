terraform {

  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    hetznerdns = {
      source="timohirt/hetznerdns"
    }
  }
   backend "consul" {
    path  = "terraform/infra"
  }
 required_version = ">= 0.13"
}

provider "hcloud" {
  token = var.hcloud_token
}
provider "hetznerdns" {
    apitoken = var.hdns_token
}
