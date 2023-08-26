data "vault_policy_document" "snapshot" {
    rule {
        path= "sys/storage/raft/snapshot"
        capabilities = ["read"]
    }
}
resource "vault_policy" "snapshot" {
  name = "snapshot"
  policy = data.vault_policy_document.snapshot.hcl
}
data "vault_policy_document" "nomad_server_policy" {
  rule {
    path = "auth/token/create/nomad-cluster"
    capabilities = ["update"]
  }
  rule {
    path = "auth/token/roles/nomad-cluster"
    capabilities = ["read"]
  }

  rule {
    path = "auth/token/lookup"
    capabilities = ["update"]
  }
  rule {
    path  = "sys/capabilities-self"
    capabilities = ["update"]
  }

  rule {
    path = "auth/token/revoke-accessor" 
    capabilities = ["update"]
  }

  rule {
    path = "sys/capabilities-self"
    capabilities = ["update"]
  }
  rule {
    path = "auth/token/renew-self"
    capabilities = ["update"]
  }
}

resource "vault_policy" "nomad-server-policy" {
  name = "nomad-server-policy"
  policy = data.vault_policy_document.nomad_server_policy.hcl
}

data "vault_policy_document" "ansible" {
  rule {
    path = "secrets/data/ansible/*"
    capabilities = ["read", "list"]
  }
  rule {
    path = "secrets/data/ansible"
    capabilities = ["read", "list"]
  }
  rule {
    path = "secrets/data/database"
    capabilities = ["read", "list"]
  }
  rule {
    path = "secrets/data/database/*"
    capabilities = ["read", "list"]
  }


}
resource "vault_policy" "ansible" {
  name = "ansible"
  policy= data.vault_policy_document.ansible.hcl
}

data "vault_policy_document" "admin_policy" {
  rule {
    path = "auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
  rule {
    path = "sys/auth/*"
    capabilities = ["create", "update", "delete", "sudo"]
  }
  rule {
    path = "sys/auth"
    capabilities = ["read"]
  }
  rule {
    path = "sys/health"
    capabilities = ["read", "sudo"]
  }
  rule {
    path = "sys/policies/acl"
    capabilities = ["list"]
  }
  rule {
    path = "sys/policies/acl/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
  rule {
    path = "secrets/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
  rule {
    path = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
   } 
  rule {
    path = "sys/mounts"
    capabilities  = ["read","list"]
  }
  rule {
    path = "sys/leases/*"
    capabilities  = ["create", "read", "update", "delete", "list", "sudo"]
  }
  rule {
    path = "sys/leases/lookup"
    capabilities  = ["list","sudo"]
  }
}
resource "vault_policy" "admin_policy" {
  name = "admin_policy"
  policy= data.vault_policy_document.admin_policy.hcl
}
