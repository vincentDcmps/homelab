resource "vault_ldap_auth_backend" "ldap" {
    path        = "ldap"
    url         = "ldap://ldap.ducamps.eu"
    userdn      = "dc=ducamps,dc=win"
    userattr    = "uid"
    discoverdn  = false
    groupdn     = "cn=groups,dc=ducamps,dc=win"
    groupfilter = "(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
    binddn      = "uid=vaultserviceaccount,cn=users,dc=ducamps,dc=win"
    groupattr   = "cn"
    bindpass    = var.ldap_bindpass
}


resource "vault_ldap_auth_backend_group" "vault_admin" {
    groupname = "vault_admin"
    policies  = ["admin_policy"]
    backend   = vault_ldap_auth_backend.ldap.path
}
