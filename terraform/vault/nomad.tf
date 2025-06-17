locals {
  allowed_policies= concat(local.nomad_policy,local.nomad_custom_policy[*].name,["nomad-workloads"])
 
  nomad_policy=[
    "crowdsec",
    "dump",
    "dentrite",
    "droneci",
    "traefik",
    "gitea",
    "grafana",
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
    "immich",
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



resource "vault_jwt_auth_backend" "nomad" {
  path               = "jwt-nomad"
  description        = "JWT auth backend for Nomad"
  jwks_url           = "http://nomad.service.consul:4646/.well-known/jwks.json"
  jwt_supported_algs = ["RS256", "EdDSA"]

  # default_role is the role applied to tokens derived from this auth method
  # when no role is specified in the request.
  #
  # The final role value is determined from the following values, from highest
  # to lowest precedence:
  #   1. The "task.vault.role" field of the job.
  #   2. The "group.vault.role" field of the job.
  #   3. The "vault.create_from_role" configuration of the Nomad client running
  #      the task.
  #   4. This "default_role" value.
  default_role = "nomad-workload"
}

resource "vault_jwt_auth_backend_role" "nomad_workload" {
  backend   = vault_jwt_auth_backend.nomad.path
  role_name = "nomad-workload"
  role_type = "jwt"

  bound_audiences = ["vault.io"]

  # user_claim is used to uniquely identity a user in Vault by mapping tokens
  # to an entity alias.
  #
  # You must use the job ID in Vault Enterprise to comply with billing and
  # Terms of Service requirements.
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true

  claim_mappings = {
    nomad_namespace = "nomad_namespace"
    nomad_job_id    = "nomad_job_id"
    nomad_group     = "nomad_group"
    nomad_task      = "nomad_task"
  }

  # token_type should be "service" so Nomad can renew them throughout the
  # task's lifecycle. Tokens of type "batch" cannot be renewed and may result
  # in errors if the task outlives the token TTL and tries to access Vault.
  token_type     = "service"
  token_policies = local.allowed_policies

  # token_period is the token TTL set after each renewal. Nomad automatically
  # renews Vault tokens before they expire for as long as the task runs and the
  # Nomad client has connectivity to the Vault cluster.
  #
  # Since Nomad uses periodic tokens, token_period should be used instead of
  # token_ttl. Refer to Vault documentation for more details.
  # https://developer.hashicorp.com/vault/docs/concepts/tokens#periodic-tokens
  token_period = 259200

  # token_explicit_max_ttl must be 0 so Nomad can renew tokens for as long as
  # the task runs.
  token_explicit_max_ttl = 0
}

resource "vault_policy" "nomad_workload" {

      name   = "nomad-workloads"
        policy = <<EOT
        path "secrets/data/nomad/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}/*" {
            capabilities = ["read"]
        }
        path "secrets/data/nomad/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}" {
            capabilities = ["read"]
        }
        path "secrets/data/database/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}/*" {
            capabilities = ["read"]
        }

        path "secrets/data/database/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}" {
            capabilities = ["read"]
        }
        path "secrets/data/authelia/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}" {
            capabilities = ["read"]
        }

        path "secrets/metadata/*" {
            capabilities = ["list"]
        }
        EOT
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

