
resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "vault-snapshot" {
  backend        = vault_auth_backend.approle.path
  role_name      = "vault-snapshot"
  token_policies = ["vault-snapshot"]
}


data "vault_approle_auth_backend_role_id" "vault-snapshot" {
    backend   = vault_auth_backend.approle.path
    role_name = vault_approle_auth_backend_role.vault-snapshot.role_name
}
output "vault-snapshot-role-id" {
      value = data.vault_approle_auth_backend_role_id.vault-snapshot.role_id
}

data "vault_policy_document" "vault-snapshot" {
  rule {
      path = "sys/storage/raft/snapshot"
      capabilities = ["read"]
  }  
}

resource "vault_policy" "vault-snapshot" {
    name = "vault-snapshot"
    policy = data.vault_policy_document.vault-snapshot.hcl
}


#resource "vault_approle_auth_backend_role_secret_id" "vault-snapshot" {
#    backend   = vault_auth_backend.approle.path
#    role_name = vault_approle_auth_backend_role.vault-snapshot.role_name
#}


