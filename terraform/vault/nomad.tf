locals {
  allowed_policies= concat(local.nomad_policy,local.nomad_custom_policy[*].name)
 
  nomad_policy=[
    "crowdsec",
    "dump",
    "dentrite",
    "droneci",
    "traefik",
    "gitea",
    "nextcloud",
    "paperless",
    "pihole",
    "prometheus",
    "rsyncd",
    "seedbox",
    "supysonic",
    "ttrss",
    "vaultwarden",
    "wikijs",
    "vikunja",
    "ghostfolio",
    "alertmanager",
    "vault-backup",
    "pdns",
    "ldap",
    "borgmatic",
    "mealie",
  ]
nomad_custom_policy = [
    {
      name = "authelia",
      policy=<<EOT
path "secrets/data/nomad/authelia" {
      capabilities = ["read"]
      }
path "secrets/data/authelia/*" {
      capabilities = ["read"]
      }
      EOT
    }
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

data "vault_policy_document" "nomad_jobs" {
  for_each = toset(local.nomad_policy)

  rule {
    path         = "secrets/data/nomad/${each.key}"
    capabilities = ["read"]
  }
  rule {
    path         = "secrets/data/nomad/${each.key}/*"
    capabilities = ["read"]
  }
  rule {
    path = "secrets/data/database/${each.key}"
    capabilities = ["read"]
  }
  rule {
    path = "secrets/data/authelia/${each.key}"
    capabilities = ["read"]
  }

}
resource "vault_policy" "nomad_jobs" {
    for_each = toset(local.nomad_policy)

    name   = each.key
    policy = data.vault_policy_document.nomad_jobs[each.key].hcl
}

resource "vault_policy" "nomad_jobs_custom" {
    for_each = {for policy in local.nomad_custom_policy: policy.name => policy}

    name   = each.value.name
    policy = each.value.policy
}

