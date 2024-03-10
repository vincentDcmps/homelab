resource "vault_ldap_auth_backend" "ldap" {
    path        = "ldap"
    url         = "ldaps://ldaps.service.consul"
    userdn      = "ou=users,dc=ducamps,dc=eu"
    userattr    = "uid"
    discoverdn  = false
    insecure_tls = true
    groupdn     = "ou=groups,dc=ducamps,dc=eu"
    groupfilter = "(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
    binddn      = "uid=vaultserviceaccount,ou=serviceAccount,ou=users,dc=ducamps,dc=eu"
    groupattr   = "cn"
    bindpass    = var.ldap_bindpass
}


resource "vault_ldap_auth_backend_group" "vault_admin" {
    groupname = "vault_admin"
    policies  = ["admin_policy"]
    backend   = vault_ldap_auth_backend.ldap.path
}
