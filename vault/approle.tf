resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "drone-vault" {
  backend        = vault_auth_backend.approle.path
  role_name      = "drone-vault"
  token_policies = ["drone-vault"]
}


data "vault_approle_auth_backend_role_id" "drone-vault" {
    backend   = vault_auth_backend.approle.path
    role_name = vault_approle_auth_backend_role.drone-vault.role_name
}
output "drone-vault-role-id" {
      value = data.vault_approle_auth_backend_role_id.drone-vault.role_id
}

data "vault_policy_document" "drone-vault" {
  rule {
      path = "secrets/data/droneCI/*"
      capabilities = ["read", "list"]
   }

}

resource "vault_policy" "drone-vault" {
    name = "drone-vault"
    policy = data.vault_policy_document.nomad_server_policy.hcl
}


resource "vault_approle_auth_backend_role_secret_id" "drone-vault" {
    backend   = vault_auth_backend.approle.path
    role_name = vault_approle_auth_backend_role.drone-vault.role_name
}


resource "vault_kv_secret_v2" "drone-vault" {
  mount                      = vault_mount.kvv2-secret.path
  name                       = "nomad/droneCI/approle"
  data_json                  = jsonencode(
  {
    approleID       = data.vault_approle_auth_backend_role_id.drone-vault.role_id,
    approleSecretID       = vault_approle_auth_backend_role_secret_id.drone-vault.secret_id
  }
  )
}
