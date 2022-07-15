terraform {
  backend "consul" {
    path  = "terraform/vault"
  }
}
provider vault {
  token = var.vault_token
}

locals {
  allowed_policies= [
    "access-tables"
  ]

}
resource "vault_token_auth_backend_role" "nomad-cluster" {
  role_name              = "nomad-cluster"
  orphan                 = true
  renewable              = true
  token_explicit_max_ttl = "0"
  token_period           = "259200"
  allowed_policies       = local.allowed_policies
}



resource "vault_mount" "kvv2-secret" {
  path = "secrets"
  type = "kv"
  options = {
    version = "2"
  }
}
