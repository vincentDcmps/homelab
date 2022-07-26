terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
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
