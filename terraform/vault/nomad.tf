locals {
  allowed_policies= concat(local.nomad_policy, [
  ])
 
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
    "torrent",
    "ldap",
    "borgmatic",
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
}
resource "vault_policy" "nomad_jobs" {
    for_each = toset(local.nomad_policy)

    name   = each.key
    policy = data.vault_policy_document.nomad_jobs[each.key].hcl
}



