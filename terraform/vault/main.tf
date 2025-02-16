terraform {
  backend "consul" {
    path  = "terraform/vault"
  }
}
provider vault {
}

resource "vault_mount" "kvv2-secret" {
  path = "secrets"
  type = "kv"
  options = {
    version = "2"
  }
}

